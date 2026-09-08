// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import { initTextareaCounter } from "./textarea_counter"

// code mostly copied (from vita-min honeycrisp.js)
var noneOfTheAbove = (function () {
  var noneOf = {
    init: function () {
      var $noneCheckbox = $('#none_of_the_above');
      var $otherCheckboxes = $('input[type=checkbox]').not('#none_of_the_above');

      // Uncheck None if another checkbox is checked
      $otherCheckboxes.click(function (e) {
        $noneCheckbox.prop('checked', false);
        $noneCheckbox.parent().removeClass('is-selected');
      });

      // Uncheck all others if None is checked
      $noneCheckbox.click(function (e) {
        $otherCheckboxes.prop('checked', false);
        $otherCheckboxes.parent().removeClass('is-selected');

        // If we just unchecked an <input> with a follow-up, let's reset the follow-up questions
        // so it hides properly.
        var $enclosingFollowUp = $noneCheckbox.closest('.question-with-follow-up');
        if ($enclosingFollowUp) {
          followUpQuestion.update($enclosingFollowUp);
        }
      });

    }
  };
  return {
    init: noneOf.init
  }
})();

// this builds on the honeycrisp question-with-follow-up pattern, allowing us to have
// a checkbox that only shows the follow-up question if it is the only one in its group
// that is checked
function applyExclusiveFollowUps() {
  $('input[data-follow-up-exclusive]').each(function () {
    var $exclusiveCheckbox = $(this);
    var selector = $exclusiveCheckbox.attr('data-follow-up');
    // regex copied from honeycrisp (honeycrisp.js:128): whitelist id/class/word characters to protect against XSS
    if (!selector || !/^[a-zA-Z0-9_\-#\.]+$/.test(selector)) return;

    var $group = $exclusiveCheckbox.closest('.question-with-follow-up__question');
    var $followUp = $(selector);
    if (!$group.length || !$followUp.length) return;

    var othersChecked = $group.find('input[type=checkbox]:checked').not($exclusiveCheckbox).length > 0;
    var show = $exclusiveCheckbox.is(':checked') && !othersChecked;

    $followUp.toggle(show);
    // also copied from honeycrisp (honeycrisp.js:120 and :126): disable/enable of the follow-up inputs so
    // hidden answers aren't submitted.
    $followUp.find('input').attr('disabled', !show);
  });
}

function initExclusiveFollowUps() {
  $(document)
    .off('click.exclusiveFollowUp')
    .on('click.exclusiveFollowUp', '.question-with-follow-up__question input', applyExclusiveFollowUps);
}

function initClickTracking() {
  document.querySelectorAll('[data-track-click]').forEach(function(el) {
    el.addEventListener('click', function() {
      if (typeof mixpanel === 'undefined') return;

      var eventName = el.getAttribute('data-track-click');
      var properties = {};

      Array.from(el.attributes).forEach(function(attr) {
        if (attr.name.startsWith('data-track-') && attr.name !== 'data-track-click') {
          // "data-track-faq-name" becomes "faq_name"
          var propName = attr.name.replace('data-track-', '').replace(/-/g, '_');
          properties[propName] = attr.value;
        }
      });

      mixpanel.track(eventName, properties);
    });
  });
}

// accordion.init() collapses every accordion. Re-open any marked with
// `accordion--default-open` so they are expanded when the page loads.
function openDefaultAccordions() {
  $('.accordion--default-open')
    .removeClass('accordion--is-closed')
    .find('.accordion__button').attr('aria-expanded', 'true');
}

// the About page is reachable from the footer of every page, so its "Go back" link
// returns visitors wherever they came from. we can't use the more common method of creating a back link
// (`link_to t("general.back"), :back`) because the app's CSP is script_src :self with no 'unsafe-inline'
// so it would do nothing
function initHistoryBackLinks() {
  document.querySelectorAll("[data-history-back]").forEach(function(el) {
    el.addEventListener("click", function(e) {
      if (window.history.length > 1) {
        e.preventDefault();
        window.history.back();
      }
    });
  });
}

document.addEventListener("turbo:load", function() {
  noneOfTheAbove.init();
  revealer.init();
  accordion.init();
  honeycrispInit();
  initExclusiveFollowUps();
  // honeycrispInit() will asychronously re-collapse the accordions and can revert any
  // show/hide state set on a question-with-follow-up before it settles (e.g. re-hiding a
  // follow-up whose driving checkbox is checked on a server-rendered validation-error
  // reload), so we use a setTimeout to redo both after that call stack unwinds.
  setTimeout(function() {
    openDefaultAccordions();
    $('.question-with-follow-up').each(function() {
      followUpQuestion.update($(this));
    });
    applyExclusiveFollowUps();
  }, 0);
  initTextareaCounter();
  initClickTracking();
  initHistoryBackLinks();
});

document.addEventListener("turbo:render", function () {
  revealer.init();
  accordion.init();
  setTimeout(openDefaultAccordions, 0);
});
