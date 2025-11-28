// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
import recipients_actions_controller from "./recipients_actions_controller"
application.register("recipient-actions", recipients_actions_controller);