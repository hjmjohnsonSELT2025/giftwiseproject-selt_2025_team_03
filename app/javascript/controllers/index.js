import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import new_recipient_controller from "controllers/new_recipient_controller"
application.register("new-recipient", new_recipient_controller)

import login_controller from "controllers/login_controller"
application.register("login", login_controller)

import profile_controller from "controllers/profile_dropdown_controller"
application.register("profile-dropdown", profile_controller)

import user_card_controller from "controllers/user_card_controller"
application.register("user-card", user_card_controller)

import users_new_controller from "controllers/users_new_controller"
application.register("users-new", users_new_controller)

import users_update_controller from "controllers/users_update_controller"
application.register("users-update", users_update_controller)

//import user_update_controller from "controllers/user_update_controller"
//application.register("current-user-update", user_update_controller)
