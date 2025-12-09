import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        $(".user-card").on('click', function() {
            $(this).toggleClass("is-expanded");
        });
        
    }
}