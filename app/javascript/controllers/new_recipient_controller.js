import { Controller } from "@hotwired/stimulus"

// data-controller='new-recipient'
export default class extends Controller {
    connect() {
        this.$select = $("#relationship-selector")
        this.$area = $("#other-relationship-wrap")
        
        const toggle = () => {
            const isOther = this.$select.val() === "Other"
            this.$area.prop("hidden", !isOther)
        }
        toggle()
        this.$select.on('change', toggle)
    }
}