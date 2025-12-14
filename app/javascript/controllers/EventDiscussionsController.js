import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  keydown(e) {
    const isCombo = e.key === "Enter" && (e.metaKey || e.ctrlKey);
    if (!isCombo) return;

    const field = e.target;
    if (!field || typeof field.value !== "string") return;
    if (field.value.trim().length === 0) return;
    e.preventDefault();
    this.element.requestSubmit();
  }
}
