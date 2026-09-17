module TextScaling
  # Honeycrisp sets html { font-size: 62.5% }, which is relative to the browser's
  # default font size, so raising that default is what happens when a participant
  # increases the font size on their phone. 32px default -> 10px * 2 = 20px root,
  # i.e. the 200% that WCAG 1.4.4 (Resize Text) asks us to support.
  LARGE_DEFAULT_FONT_SIZE = 32
  EXPECTED_LARGE_ROOT_FONT_SIZE = 20

  # 390px is an iPhone 14/15 in portrait, the width the bug was reported at.
  # 1000px is past the 800px breakpoint, where the card takes on its roomier
  # desktop padding and can squeeze the content column harder than the phone does.
  PHONE_VIEWPORT = {width: 390, height: 844}.freeze
  DESKTOP_VIEWPORT = {width: 1000, height: 1400}.freeze

  # Reports horizontal overflow of the document, naming the widest offending
  # elements so a failure says which component broke rather than just "the page
  # is too wide". WCAG 1.4.10 (Reflow) wants no horizontal scrolling at all.
  OVERFLOW_SCRIPT = <<~JS.freeze
    var doc = document.documentElement;
    // sub-pixel layout rounding can leave a 1px discrepancy that no user sees
    if (doc.scrollWidth - doc.clientWidth <= 1) return null;

    var offenders = [];
    document.querySelectorAll("body *").forEach(function (el) {
      var rect = el.getBoundingClientRect();
      if (rect.width === 0 || rect.height === 0) return;
      var over = Math.round(rect.right - doc.clientWidth);
      if (over <= 1) return;
      // only report the innermost offender: a parent is usually only wide
      // because of a child, and listing the whole ancestor chain is noise
      if (Array.prototype.some.call(el.children, function (child) {
        return Math.round(child.getBoundingClientRect().right - doc.clientWidth) > 1;
      })) return;
      offenders.push({
        over: over,
        selector: el.tagName.toLowerCase() + (el.className && typeof el.className === "string" ? "." + el.className.trim().split(/\\s+/).join(".") : ""),
        width: Math.round(rect.width),
        text: (el.textContent || "").trim().replace(/\\s+/g, " ").slice(0, 60)
      });
    });
    offenders.sort(function (a, b) { return b.over - a.over });

    return {
      scrollWidth: doc.scrollWidth,
      clientWidth: doc.clientWidth,
      offenders: offenders.slice(0, 5)
    };
  JS

  # Set OVERFLOW_DEBUG=1 to print the layout chain above each offending element.
  # Knowing which ancestor is actually imposing the width is most of the work in
  # tracking one of these down, and it is tedious to reconstruct after the fact.
  ANCESTOR_CHAIN_SCRIPT = <<~JS.freeze
    var el = document.querySelector(selector);
    if (!el) return "  (element no longer present: " + selector + ")";

    var lines = [];
    var node = el;
    while (node && node !== document.documentElement) {
      var cs = getComputedStyle(node);
      var rect = node.getBoundingClientRect();
      var name = node.tagName.toLowerCase() +
        (typeof node.className === "string" && node.className ? "." + node.className.trim().split(/\\s+/).join(".") : "");
      lines.push(
        "    " + name +
        "\\n      left=" + Math.round(rect.left) + " width=" + Math.round(rect.width) +
        " display=" + cs.display +
        "\\n      width:" + cs.width + " minWidth:" + cs.minWidth + " maxWidth:" + cs.maxWidth +
        "\\n      padding:" + cs.paddingLeft + "/" + cs.paddingRight +
        " margin:" + cs.marginLeft + "/" + cs.marginRight +
        " overflowWrap:" + cs.overflowWrap + " whiteSpace:" + cs.whiteSpace
      );
      node = node.parentElement;
    }
    return lines.join("\\n");
  JS

  def ancestor_chain(selector)
    page.evaluate_script("(function (selector) { #{ANCESTOR_CHAIN_SCRIPT} })(#{selector.to_json})")
  end

  # Chrome will not open a window narrower than ~500px, so the layout viewport is
  # set through CDP rather than by resizing.
  #
  # Called with a document already loaded, and the result confirmed rather than
  # assumed: the override binds to a page target, so applying it before any
  # navigation leaves it on whatever target the session started on. Nothing has
  # been observed going wrong locally or in CI from the old order -- the failure
  # that prompted this was the scrollbar measurement below -- but the override is
  # cheap to verify and expensive to debug when silently absent.
  def emulate_viewport(viewport)
    @emulated_viewport = viewport

    3.times do
      page.driver.browser.execute_cdp(
        "Emulation.setDeviceMetricsOverride",
        width: viewport[:width], height: viewport[:height],
        deviceScaleFactor: 1,
        # mobile: false keeps Chrome's text autosizing out of the measurements,
        # so what we measure is our own CSS rather than a browser heuristic
        mobile: false
      )
      # innerWidth so a classic scrollbar does not make a successful override
      # look like a failed one and spin this loop -- see
      # expect_text_to_be_scaled_up
      return if page.evaluate_script("window.innerWidth") == viewport[:width]

      sleep 0.2
    end
  end

  def root_font_size
    page.evaluate_script("parseFloat(getComputedStyle(document.documentElement).fontSize)")
  end

  def horizontal_overflow
    page.evaluate_script("(function () { #{OVERFLOW_SCRIPT} })()")
  end

  # Guards against the audit silently passing because the font-size emulation or
  # the viewport override stopped working -- a green run then would mean nothing.
  def expect_text_to_be_scaled_up
    actual_root = root_font_size
    expect(actual_root).to eq(EXPECTED_LARGE_ROOT_FONT_SIZE),
      "expected a #{EXPECTED_LARGE_ROOT_FONT_SIZE}px root font size (200% text) but got " \
      "#{actual_root}px -- the driver's font-size preference is not taking effect"
    # innerWidth, not documentElement.clientWidth: clientWidth excludes a
    # classic vertical scrollbar, so on Linux it reads 15px narrower than the
    # viewport actually is and this guard would fail a working override. The
    # overflow check below does want clientWidth -- that is the content area
    # content has to fit inside.
    expected_width = @emulated_viewport.fetch(:width)
    actual_width = page.evaluate_script("window.innerWidth")
    expect(actual_width).to eq(expected_width),
      "expected a #{expected_width}px layout viewport but got #{actual_width}px -- the CDP " \
      "metrics override is not taking effect, so nothing here is being measured at the " \
      "width it claims"
  end

  def text_scaling_offenses
    @text_scaling_offenses ||= []
  end

  def audited_paths
    @audited_paths ||= []
  end

  # Narrows the audit to the given paths, given without the locale prefix. Most
  # of the NC flow is the same pages as the DE flow, so its scenario only pays
  # for the handful that actually differ instead of re-checking twenty identical
  # pages; the rest of its walk is just navigation to reach them.
  def only_check_paths(*paths)
    @paths_to_check = paths.flatten
  end

  # /en/homeschool -> /homeschool, so callers can name paths without caring which
  # locale the flow happens to be running in.
  def current_path_without_locale
    page.current_path.sub(%r{\A/(?:en|es)(?=/|\z)}, "")
  end

  def page_checks
    @page_checks ||= {}
  end

  # Registers an extra assertion to run when the walk reaches a given page, at the
  # same settled moment as the overflow check. Overflow alone cannot catch a field
  # that has been squeezed too narrow to read while still fitting the viewport.
  def check_on_path(path, &block)
    page_checks[path] = block
  end

  # Asserts a field is wide enough to display the content it accepts. Measured
  # against the field's own font, so it holds at any text size.
  def expect_field_to_show(selector, text)
    needed, available = page.evaluate_script(<<~JS)
      (function () {
        var el = document.querySelector(#{selector.to_json});
        var probe = document.createElement("span");
        probe.style.font = getComputedStyle(el).font;
        probe.style.position = "absolute";
        probe.style.whiteSpace = "pre";
        probe.textContent = #{text.to_json};
        document.body.appendChild(probe);
        var needed = probe.getBoundingClientRect().width;
        probe.remove();
        return [Math.ceil(needed), Math.floor(el.clientWidth)];
      })();
    JS

    expect(available).to be >= needed,
      "#{selector} on #{current_path_without_locale} is #{available}px wide, but #{text.inspect} " \
      "needs #{needed}px at this text size -- the content it holds cannot be read"
  end

  # Runs the current page's checks and records any overflow. Records rather than
  # raises, so one run reports every page that breaks instead of stopping at the
  # first; report_text_scaling_offenses! does the failing.
  def audit_current_page
    path = current_path_without_locale
    return if @paths_to_check && !@paths_to_check.include?(path)

    audited_paths << path unless audited_paths.include?(path)
    page_checks[path]&.call

    overflow = horizontal_overflow
    return if overflow.nil?
    return if text_scaling_offenses.any? { |offense| offense[:path] == path }

    if ENV["OVERFLOW_DEBUG"]
      worst = overflow["offenders"].first
      puts "\n#{path} -- layout chain above #{worst["selector"]}:\n#{ancestor_chain(worst["selector"])}"
    end

    text_scaling_offenses << {path: path, overflow: overflow}
  end

  # A narrowed audit that never reaches its pages would pass while checking
  # nothing, so a renamed or reordered route fails here rather than going quiet.
  def expect_audited_paths_reached
    return if @paths_to_check.nil?

    missed = @paths_to_check - audited_paths
    expect(missed).to be_empty,
      "these paths were never reached, so nothing checked them: #{missed.join(", ")}"
  end

  # Ends the audit: confirms it covered what it claimed to, then fails with every
  # page that overflowed.
  def report_text_scaling_offenses!
    expect_audited_paths_reached
    return if text_scaling_offenses.empty?

    report = text_scaling_offenses.map do |offense|
      overflow = offense[:overflow]
      widest = overflow["offenders"].map do |o|
        "    #{o["selector"]}\n      #{o["width"]}px wide, #{o["over"]}px past the right edge\n      #{o["text"].inspect}"
      end.join("\n")
      "  #{offense[:path]} (#{overflow["scrollWidth"]}px document in a #{overflow["clientWidth"]}px viewport)\n#{widest}"
    end.join("\n\n")

    raise <<~MESSAGE
      #{text_scaling_offenses.count} page(s) scroll sideways at 200% text (WCAG 1.4.10 Reflow):

      #{report}
    MESSAGE
  end

  # Audits before the click rather than after: Capybara has just resolved the
  # element being clicked, so the page is settled. Checking afterwards would race
  # the next page's render and make the audit flaky.
  module AuditsEachPageBeforeClick
    def click_on(*, **)
      audit_current_page
      super
    end
  end
end
