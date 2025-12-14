import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close() {
    const frame = document.getElementById("modal")
    if (frame) frame.innerHTML = ""
  }

  backdrop(e) {
    if (e.target.classList.contains("modal-overlay")) this.close()
  }
}
