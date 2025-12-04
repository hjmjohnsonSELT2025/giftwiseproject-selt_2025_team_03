import { Controller } from "@hotwired/stimulus"

// data-controller="new-user"
export default class extends Controller {
    #updateSubmit() {
        this.$submit.prop('disabled', this.#requiredUnfulfilled())
    }
    #requiredUnfulfilled() {
        return this.requiredInputs.filter('.error').length > 0
    }

    #setOK($input, $label) {
        $label.removeClass('error')
        $input.removeClass('error')
        $label.find('span.error').remove()
    }

    #setInvalid($input, $label, message = "Required") {
        $label.addClass('error')
        $input.addClass('error')
        const $msg = $label.find('span.error')
        if ($msg.length === 0) {
            $label.append($('<span>', { class: 'error', text: message }))
        } else {
            $msg.text(message)
        }
    }

    #validateAndUpdate($inputField, $label) {
        if (!$inputField.hasClass('required')) return

        if ($inputField.is('#user_email')) {
            const value = $inputField.val().trim()

            const validStr = () =>
                value.length > 0 && this.emailRegex.test(value)

            if (!validStr()) {
                this.#setInvalid($inputField, $label, "Invalid email.")
                return
            }
            $.ajax({
                url: '/users/check_email',
                method: 'POST',
                dataType: 'json',
                data: { email: value },
                headers: { 'X-CSRF-Token': $("meta[name='csrf-token']").attr('content') },
            })
                .done((_data, _status, _xhr) => {
                    this.#setOK($inputField, $label)
                    this.#updateSubmit()
                })
                .fail((xhr) => {
                    if (xhr.status === 409) {
                        this.#setInvalid($inputField, $label, "Email already in use.")
                    } else {
                        this.#setOK($inputField, $label)
                    }
                    this.#updateSubmit()
                })

            return
        }
        if ($inputField.is('input:password')) {
            if ($inputField.is('#user_password_confirm')) {
                if ($inputField.val().trim() !== $('#user_password').val().trim()) {
                    this.#setInvalid($inputField, $label, "Passwords must match.")
                } else {
                    this.#setOK($inputField, $label)
                }
            } else if ($inputField.is('#user_password')) {
                const strong = () => this.passwordRegex.test($inputField.val().trim())
                if (strong()) {
                    this.#setOK($inputField, $label)
                } else {
                    this.#setInvalid(
                        $inputField,
                        $label,
                        "Password must be 8+ chars and include a number."
                    )
                }
            }
            return
        }

        if ($inputField.val().trim().length === 0) {
            this.#setInvalid($inputField, $label)
        } else {
            this.#setOK($inputField, $label)
        }
    }

    connect() {

        this.$submit = $('input[type="submit"][name="commit"]')
        this.$submit.prop('disabled', true)

        this.requiredInputs = $('input.required:text, input.required:password')

        this.emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
        this.passwordRegex = /^(?=.*\d).{8,}$/   // 8+ chars, at least one digit

        const validate = ($input, $label) => this.#validateAndUpdate($input, $label)
        const updateSubmit = () => this.#updateSubmit()

        $(".input-group").each(function () {
            const $group = $(this)
            const $input = $group.find(".input-field")
            const $label = $group.find(".input-label")

            $input.on("focusout", function () {
                validate($input, $label)
                updateSubmit()
            })
        })
    }
}
