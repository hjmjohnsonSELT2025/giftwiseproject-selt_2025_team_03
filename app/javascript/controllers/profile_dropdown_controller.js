import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="profile-dropdown"
export default class extends Controller {
  connect() {
    $(document).on('click', function(evt) {
      if (!$("#profile-menu-details").has(evt.target).length) {
        if ($("#profile-dropdown-menu").attr('open')) {
          $("#profile-dropdown-menu").removeAttr('open')
        }
      }
    })
  }
}
