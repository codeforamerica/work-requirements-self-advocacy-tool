export function initTextareaCounter() {
  document.querySelectorAll("textarea[maxlength]").forEach(textarea => {
    const formGroup = textarea.closest(".form-group");
    if (!formGroup) return;

    if (formGroup.querySelector("[data-char-counter-for]")) return;

    const maxLength = parseInt(textarea.getAttribute("maxlength"), 10);
    if (!maxLength || maxLength <= 0) return;

    const template = textarea.dataset.i18nRemaining || "%{count} characters remaining";

    const counter = document.createElement("p");
    counter.className = "text--help char-counter";
    counter.setAttribute("data-char-counter-for", textarea.id);
    counter.setAttribute("data-maxlength", maxLength);
    counter.textContent = "";

    // textarea's are automagically created inside a div, so the counter will wind up inside a div
    // to remove flicker & element movement, a placeholder <p> can be added per textarea in the view
    // and this will remove the placeholder as the counter is created and inserted into the DOM
    const placeholderElement = formGroup.parentElement.querySelector(".form-group + p.char-counter.spacing-below-0");
    if (placeholderElement) {
      placeholderElement.remove();
    }

    textarea.insertAdjacentElement("afterend", counter);

    function updateCounter() {
      const remaining = maxLength - textarea.value.length;
      counter.textContent = template.replace("%{count}", remaining);
    }

    updateCounter();

    textarea.addEventListener("input", updateCounter);
  });
}

document.addEventListener("turbo:load", initTextareaCounter);
