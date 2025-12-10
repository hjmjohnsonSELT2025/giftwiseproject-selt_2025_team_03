// controllers/users_update_controller.js (or similar)
import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

export default class extends Controller {
    connect() {
        this.$root = $(this.element)

        this.setupFieldCounters()
        this.setupValidations()
    }
    disconnect() {
        if (this.$root) {
            this.$root.off(".profileValidation")
        }
    }

    setupValidations() {
        const $root = this.$root
        const $submit = $root.find("input[type='submit']") // scoped to this form/page
        const $required = $root.find("input.required[type='text'], input.required[type='password'], input.required[type='email']")

        // Start with enabled, or set to true if you really want to force validation first
        $submit.prop("disabled", false)

        const validator = {
            helpers: {
                requiredUnfulfilled() {
                    return $required.filter(".error").length > 0
                },
                setInvalid(input, label, reason) {
                    const $label = $(label)
                    const $input = $(input)

                    $label.addClass("error")
                    $input.addClass("error")

                    let $msg = $label.find("span.error")
                    if ($msg.length === 0) {
                        $msg = $("<span>", { class: "error" }).appendTo($label)
                    }
                    $msg.text(reason)

                    console.warn("Invalid field received.")
                    updateSubmit()
                },
                setOK(input, label) {
                    const $label = $(label)
                    const $input = $(input)

                    $label.removeClass("error")
                    $input.removeClass("error")
                    $label.find("span.error").remove()

                    console.log("Setting field to OK.")
                    updateSubmit()
                },
            },

            email(input, label) {
                const _emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9]{2,}$/
                const val = $(input).val().trim()

                if (!(val.length > 0 && _emailRegex.test(val))) {
                    validator.helpers.setInvalid(input, label, "Invalid email address.")
                    return
                }

                $.ajax({
                    url: "/users/check_email",
                    method: "POST",
                    dataType: "json",
                    data: { email: val },
                    headers: {
                        "X-CSRF-Token": $("meta[name='csrf-token']").attr("content"),
                    },
                })
                    .done(function () {
                        validator.helpers.setOK(input, label)
                    })
                    .fail(function (xhr) {
                        if (xhr.status === 409) {
                            validator.helpers.setInvalid(input, label, "Email already in use.")
                        } else {
                            validator.helpers.setOK(input, label)
                        }
                    })
            },

            password(input, label) {
                const _passwordRegex = /^(?=.*\d).{8,}$/

                const types = {
                    regular() {
                        const strong = _passwordRegex.test($(input).val().trim())
                        if (strong || $(input).val().trim().length === 0) {
                            // allow blank, e.g., on profile update
                            validator.helpers.setOK(input, label)
                        } else {
                            validator.helpers.setInvalid(
                                input,
                                label,
                                "Password must be 8+ characters and include a number."
                            )
                        }
                    },
                    confirm() {
                        if ($(input).val().trim() !== $("#user_password").val().trim()) {
                            validator.helpers.setInvalid(input, label, "Passwords must match.")
                        } else {
                            validator.helpers.setOK(input, label)
                        }
                    },
                }

                if ($(input).is("#user_password_confirm")) {
                    types.confirm()
                } else {
                    types.regular()
                }
            },

            other(input, label) {
                if ($(input).val().trim().length === 0) {
                    validator.helpers.setInvalid(input, label, "This field is required.")
                } else {
                    validator.helpers.setOK(input, label)
                }
            },
        }

        const updateSubmit = () => {
            // disable if ANY required field has an error
            $submit.prop("disabled", validator.helpers.requiredUnfulfilled())
        }

        const validate = (input, label) => {
            const $input = $(input)
            if (!$input.hasClass("required")) return

            if ($input.is("#user_email")) {
                validator.email(input, label)
            } else if ($input.is("input[type='password']")) {
                validator.password(input, label)
            } else {
                validator.other(input, label)
            }
        }

        // Attach namespaced handlers only inside this controller element
        $root.on(
            "focusout.profileValidation",
            ".input-group-required",
            function () {
                const $group = $(this)
                const $input = $group.find("input[type='text'], input[type='password'], input[type='email']")
                const $label = $group.find(".required-label")
                validate($input, $label)
            }
        )
    }

    setupFieldCounters() {
        const $root = this.$root

        const limitedFields = [
            {
                field: $root.find("#interests-field"),
                counter: $root.find("#interests-counter"),
            },
            {
                field: $root.find("#aversions-field"),
                counter: $root.find("#aversions-counter"),
            },
        ]

        limitedFields.forEach(({ field, counter }) => {
            if (field.length && counter.length) {
                $root.on("input.profileValidation", field, function (e) {
                    counter.text(e.currentTarget.value.length)
                })
            }
        })
    }
}
