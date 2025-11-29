// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import recipients_controller from "controllers/recipients_controller"
application.register("recipients", recipients_controller)

import login_controller from "controllers/login_controller"
application.register("login", login_controller)

import profile_controller from "controllers/profile_dropdown_controller"
application.register("profile-menu", profile_controller)

import new_user_controller from "controllers/new_user_controller"
application.register("new-user", new_user_controller)