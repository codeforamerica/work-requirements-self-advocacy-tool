export function initTextareaCounter() {
  document.querySelectorAll("textarea[maxlength]").forEach(textarea => {
    const formGroup = textarea.closest(".form-group");
    if (!formGroup) return;

    // Prevent double-initialization
    if (formGroup.querySelector("[data-char-counter-for]")) return;

    const maxLength = parseInt(textarea.getAttribute("maxlength"), 10);
    if (!maxLength || maxLength <= 0) return;

    const counter = document.createElement("p");
    counter.className = "text--help char-counter";
    counter.setAttribute("data-char-counter-for", textarea.id);
    counter.setAttribute("data-maxlength", maxLength);
    counter.textContent = "";

    // Remove placeholder to avoid layout shift
    const placeholderElement = formGroup.parentElement.querySelector(".form-group + p.char-counter.spacing-below-0");
    if (placeholderElement) {
      placeholderElement.remove();
    }

    textarea.insertAdjacentElement("afterend", counter);

    function updateCounter() {
      const remaining = maxLength - textarea.value.length;

      const oneTemplate = textarea.dataset.i18nOne;
      const otherTemplate = textarea.dataset.i18nOther;

      if (oneTemplate && otherTemplate) {
        const template = remaining === 1 ? oneTemplate : otherTemplate;
        counter.textContent = template.replace("%{count}", remaining);
      }
    }

    updateCounter();
    textarea.addEventListener("input", updateCounter);
  });
}

document.addEventListener("turbo:load", initTextareaCounter);