// app/javascript/controllers/recipient_controller.js
import { Controller } from "@hotwired/stimulus"
const SELECTED_CLASS = "selected"
export default class extends Controller {
    connect() {
        this.handleKeyDown = this.handleKeyDown.bind(this)
        this.handleGlobalClick = this.handleGlobalClick.bind(this)
        document.addEventListener("keydown", this.handleKeyDown)
        document.addEventListener("click", this.handleGlobalClick)
    }
    disconnect() {
        document.removeEventListener("keydown", this.handleKeyDown)
        document.removeEventListener("click", this.handleGlobalClick)
    }
    handleKeyDown(event) {
        if (event.key === "Escape") {
            this.clearAllSelections()
        }
        switch (event.key) {
            case 'Escape':
                this.clearAllSelections(); break
            default: break
        }
    }
    handleGlobalClick(event) {
        const cardSelector = "[data-controller='recipient']"
        if (event.target.closest(cardSelector)) return
        this.clearAllSelections()
    }
    clearAllSelections() {
        document
            .querySelectorAll("[data-controller='recipient']")
            .forEach(el => el.classList.remove(SELECTED_CLASS))
    }
    preventSelection(event) {
        if (event.button === 0) {
            event.preventDefault()
        }
    }
    click(event) {
        const $card = $(this.element)
        if (event.shiftKey) {
            $card.toggleClass(SELECTED_CLASS)
        } else {
            $("[data-controller='recipient']")
                .not(this.element)
                .removeClass(SELECTED_CLASS)

            $card.addClass(SELECTED_CLASS)
        }
    }
}