/*
console.log("email validator loaded.");

$(function() {
    const emailField = $("#email_field_input");
    const infoField = $("#email_info");
    const valid_email_str = (str) => {
        const match = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        return match.test(str);
    }
    const onOkReceived = (response) => {
        console.log("received OK from server from AJAX request");
        infoField.removeClass("warn").addClass("ok");
        infoField.text("Email available.");
    }
    const onFailReceived = (response) => {
        console.log(`received from server: ${response.data}`);
        infoField.removeClass("ok").addClass("warn");
        if (response.status === 409) {
            infoField.removeClass("ok").addClass("warn");
            infoField.text("Email already in use.");
        } else {
            infoField.removeClass("ok").addClass("error");
            infoField.text("Error with server.");
        }
    }
    
    emailField.on("focusout", () => {
        console.log("Verifying email...");
        if (valid_email_str(emailField.val())) {
            console.log("Valid email string. Sending request to server....");
            $.ajax({
                url: "/users/check_email",
                method: "POST",
                dataType: "json",
                data: {
                    email: emailField.val()
                },
                headers: {
                    "X-CSRF-Token": $("meta[name='csrf-token']").attr("content")
                },
                success: onOkReceived,
                error: onFailReceived
            });
        } else {
            console.log("Invalid email string.");
            infoField.removeClass("ok").addClass("warn");
            infoField.text("Invalid email address.")
        }
    });
});
*/
$(() => {
    const validateRequiredFieldsSetup = () => {
        const injectStyle = () => {
            $('<style id="js-style">').text(`
                .error-text { color:#ff0000; margin-left: 10px; font-style: italic; }
                .error-input { outline: 1px solid #ff0000; }
            `).appendTo('head');
        };
        const $submitButton = $('input[type="submit"][name="commit"]');
        const updateSubmitButton = () => {
            const anyEmpty = $('.required:text, .required:password')
            .toArray()
            .some(function(item) {
                return $(item).val().trim().length === 0;
            });
            $submitButton.prop("disabled", anyEmpty);
        };
        $(".input-group").each(function() {
            const $input = $(this).find(".input-field");
            const $label = $(this).find(".input-label");
            if (!$input.hassClass('required')) {
                if (!$input.is("#email")) {
                    const validate = () => {
                        const empty = !$input.val().trim();
                        if (empty) {
                            if (!$label.find('.error-text').length) {
                                $label.append($('<span>', { class: 'error-text', text: ' Required'}));
                            }
                            $input.addClass('error-input');
                        } else {
                            $label.find('.error-text').remove();
                            $input.removeClass('error-input');
                        }
                        updateSubmitButton();
                    };
                    $input.on('input blur', validate);
                    validate(); // initialize
                } else {
                    
                }
            }
        });
        updateSubmitButton();
    }
    const validateEmailSetup = () => {
        const $email = $("#email");
        
    }
});