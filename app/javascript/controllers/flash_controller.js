import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        timeout: { type: Number, default: 2000 },
        okAction: String
    }
    connect() {
        if (this.timeoutValue > 0) {
            this.timer = setTimeout(() => this.close(), this.timeoutValue)
        }
    }
    disconnect() {
        if (this.timer) clearTimeout(this.timer)
    }
    close() {
        this.element.classList.add("flash--hiding")
        this.element.addEventListener('transitionend', 
            () => this.element.remove(), 
            { once:true }
        )
    }
}