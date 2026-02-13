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

var followUpQuestion = (function() {
  var fUQ = {
    init: function() {
      $('.question-with-follow-up').each(function(index, question) {
        var self = this;

        // set initial state of follow-ups based on the page
        $(this).find('input').each(function(index, input) {
          if($(this).attr('data-follow-up') != null) {
            $($(this).attr('data-follow-up')).toggle($(this).is(':checked'));
          }
        });
        fUQ.update($(self))

        // add click listeners to initial question inputs
        $(self).find('.question-with-follow-up__question input').click(function(e) {fUQ.update($(self))})
      });
    },
    update: function ($container){
      // reset follow ups
      $container.find('.question-with-follow-up__follow-up input').attr('disabled', true);
      $container.find('.question-with-follow-up__follow-up').hide();

      $container.find('.question-with-follow-up__question input').each(function(index, input) {
        // if any of the inputs with a data-follow-up is checked then show the follow-up
        if($(input).is(':checked') && $(input).attr('data-follow-up') != null) {
          $container.find('.question-with-follow-up__follow-up input').attr('disabled', false);
          var followUpSelector = $(this).attr('data-follow-up');
          if (/^[a-zA-Z0-9_\-#\.]+$/.test(followUpSelector)) {
            $(followUpSelector).show();
          }
        }
      });
    }
  }
  return {
    init: fUQ.init,
    update: fUQ.update
  }
})();

document.addEventListener("turbo:load", function() {
  noneOfTheAbove.init();
  revealer.init();
  honeycrispInit();
  followUpQuestion.init();
  initTextareaCounter();
});

document.addEventListener("turbo:render", function () {
  revealer.init();
});
