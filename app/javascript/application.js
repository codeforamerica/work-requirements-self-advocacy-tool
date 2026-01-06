// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// code mostly copied (from vita-min honeycrisp.js)
var noneOfTheAbove = (function () {
  var noneOf = {
    init: function () {
      var $noneCheckbox = $('#screener_none');
      var $otherCheckboxes = $('input[type=checkbox]').not('#screener_none');

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

noneOfTheAbove.init();
