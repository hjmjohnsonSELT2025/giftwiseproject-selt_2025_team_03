import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    #emptyField(item) {
        return item.val().trim().length === 0
    }
    connect() {
        this.targets = $(".required").toArray()
        this.$submit = $('input[type="submit"][name="commit"]')

        this.targets.forEach(function(target) {
            target.on("input blur", function() {
                this.$submit.prop('disabled', 
                    this.targets.some((item) => this.#emptyField(item))
                )
            })
        })
        this.$submit.prop('disabled', true)
    }
}