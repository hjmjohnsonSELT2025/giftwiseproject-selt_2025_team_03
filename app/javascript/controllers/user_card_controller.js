import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        console.log("User card connected.");
        $(this.element).on('click.card', function(e) {
            if ($(e.target).closest('a,button,input,textarea,select,label,form').length) return;
            $(this).toggleClass("is-expanded");
        });   
    }
    disconnect() {
        $(this.element)?.off("click.card");
    }
    collapse() {
        $(this.element).removeClass("is-expanded");
    }
}