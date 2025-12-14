import { Application } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"
import TC from "@rolemodel/turbo-confirm"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

import $ from "jquery";
window.$ = $;
window.jQuery = $;
export { application }
TC.start()
