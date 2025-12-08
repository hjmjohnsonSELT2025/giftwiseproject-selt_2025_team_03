import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import new_recipient_controller from "controllers/new_recipient_controller"
application.register("new-recipient", new_recipient_controller)

import login_controller from "controllers/login_controller"
application.register("login", login_controller)

import profile_controller from "controllers/profile_dropdown_controller"
application.register("profile-dropdown", profile_controller)

import new_user_controller from "controllers/new_user_controller"
application.register("new-user", new_user_controller)

//import user_update_controller from "controllers/user_update_controller"
//application.register("current-user-update", user_update_controller)