$(() => {
    console.log("Setting up validation for required fields and validation for email.");
    const validateRequiredFieldsSetup = () => {
        const injectStyle = () => {
            $('<style id="js-style">').text(`
                .error-text { color:#ff0000; margin-left: 10px; font-style: italic; }
                .error-input { outline: 1px solid #ff0000; }
            `).appendTo('head');
        };
        injectStyle();
        const $submitButton = $('input[type="submit"][name="commit"]');
        const updateSubmitButton = () => {
            const anyInvalid = $('.required:text')
            .toArray()
            .some(function(item) {
                return $(item).hasClass(".error-input");
            });
            $submitButton.prop("disabled", anyInvalid);
        };
        $(".input-group").each(function() {
            const $input = $(this).find(".input-field");
            const $label = $(this).find(".input-label");
            if ($input.hasClass('required') && !$input.is("input:password")) {
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
                }
            }
        });
        updateSubmitButton();
    }
    const validateEmailSetup = () => {
        const $email = $("#email");
        const $label = $email.siblings('.input-label');
        const request = {
            url: "/users/check_email",
            method: "POST",
            dataType: "json",
            data: {
                email: $email.val()
            },
            headers: {
                "X-CSRF-Token": $("meta[name='csrf-token']").attr("content")
            },
            success: onOkReceived,
            error: onFailReceived
        };
        const validEmailStr = (str) => {
            const match = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            return match.test(str);
        }
        const setOk = () => {
            $label.find('.error-text').remove();
            $email.removeClass(".error-input");
        };
        const setInUse = () => {
            if (!$label.find('.error-text').length) {
                $label.append($('<span>', { class: 'error-text', text: ' Email already in use.'}));
            }
            $email.addClass(".error-input");
        }
        const setInvalid = () => {
            if (!$label.find('.error-text').length) {
                $label.append($('<span>', { class: 'error-text', text: ' Please enter a valid email address.'}));
            } else {
                $label.find(".error-text").text(" Please enter a valid email address.");
            }
            $email.addClass(".error-input");
        }
        const onFail = (response) => {
            console.log(`Received from server when validating email via AJAX: ${response.data}`);
            if (response.status === 409) {
                setInUse();
            } else {
                setOk();
            }
        }
        
        $email.on('change', setOk);

        $email.on('focusout', () => {
            if (validEmailStr($email.val().trim())) {
                $.ajax(request);
            } else {
                setInvalid();
            }
        });
    };
    validateRequiredFieldsSetup();
    validateEmailSetup();
});
