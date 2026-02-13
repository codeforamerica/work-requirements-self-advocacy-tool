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

var followUpQuestionModifier = (function() {
  var fUQ = {
    initUpdate: function() {
      $('.question-with-follow-up').each(function() {
        var self = this;
        followUpQuestion.update($(self));
      });
    }
  }
  return {
    initUpdate: fUQ.initUpdate,
  }
})();

document.addEventListener("turbo:load", function() {
  noneOfTheAbove.init();
  revealer.init();
  honeycrispInit();
  followUpQuestionModifier.initUpdate();
  initTextareaCounter();
});

document.addEventListener("turbo:render", function () {
  revealer.init();
});
