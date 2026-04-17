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

document.addEventListener("turbo:load", function() {
  noneOfTheAbove.init();
  revealer.init();
  accordion.init();
  honeycrispInit();
  $('.question-with-follow-up').each(function() {
    var self = this;
    followUpQuestion.update($(self));
  });
  initTextareaCounter();
  initClickTracking();
});

document.addEventListener("turbo:render", function () {
  revealer.init();
});
