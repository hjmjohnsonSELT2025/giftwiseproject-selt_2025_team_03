import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="profile-dropdown"
export default class extends Controller {
  connect() {
    this.$menu = $("#profile-dropdown-menu")
    this.$link = $('#profile-link')
    $(document).on('click', (evt) => {
      if (!this.$link.has(evt.target).length) {
        if (this.$menu.attr('open')) {
          this.$menu.removeAttr('open')
        }
      }
    })
  }
}
