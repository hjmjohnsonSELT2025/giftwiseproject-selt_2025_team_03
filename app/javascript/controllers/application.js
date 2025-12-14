import { Application } from "@hotwired/stimulus"
import TC from "@rolemodel/turbo-confirm"

const application = Application.start()
application.debug = false
window.Stimulus = application
import $ from "jquery"
window.$ = $
window.jQuery = $

TC.start()

export { application }
