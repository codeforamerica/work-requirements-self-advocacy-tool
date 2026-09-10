Grover.configure do |config|
  chrome_paths = [
    ENV["PUPPETEER_EXECUTABLE_PATH"],
    ENV["GOOGLE_CHROME_BIN"],
    ENV["GOOGLE_CHROME_SHIM"],
    "/usr/bin/chromium",
    "/app/.chrome-for-testing/chrome-linux64/chrome"
  ]

  chrome_path = chrome_paths.find { |path| path.present? && File.exist?(path) }

  # Chrome's sandbox needs a setuid-root helper or unprivileged user namespaces, neither of
  # which is reliably available in CI/containers, so it's disabled unconditionally -- not just
  # when we've found one of the container Chrome paths above.
  config.options = {launch_args: ["--no-sandbox", "--disable-setuid-sandbox"]}
  config.options[:executable_path] = chrome_path if chrome_path.present?
end
