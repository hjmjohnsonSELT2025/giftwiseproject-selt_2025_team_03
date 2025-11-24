$(() => {
    console.debug("Setting up validation for required fields and validation for email.");
    const injectStyle = () => {$('<style id="js-style">').text(`.error-text { 
    color:#ff0000; 
    margin-left: 20px; 
    font-style: italic; 
}
.error-input { outline: 1px solid #ff0000; }
.label-style { 
    display: flex; 
    justify-content: 
    space-between; 
}`).appendTo('head');
    };
    injectStyle();
    const validateRequiredFieldsSetup = () => {
        const $submitButton = $('input[type="submit"][name="commit"]');
        $submitButton.prop('disabled', true);
        console.debug(`Submit button found: ${$submitButton.length > 0}`);
        const updateSubmitButton = () => {
            const $requiredInputs = $('input.required:text, input.required:password');
            const anyInvalid = $requiredInputs.filter(".error-input").length > 0;
            $submitButton.prop('disabled', anyInvalid);
            console.debug(`Submit button state: ${$submitButton.is(':disabled') ? 'disabled' : 'enabled'}`);
        };
        
        $(".input-group").each(function() {
            const $input = $(this).find(".input-field");
            const $label = $(this).find(".input-label");
            const setOk = () => {
                $label.find('.error-text').remove();
                $input.removeClass("error-input");
                updateSubmitButton();
            };
            const setInvalid = (input, label, message) => {
                if (!label.find(".error-text").length) {
                    label.addClass("label-style");
                    label.append($('<span>', { class: "error-text", text: `${message}`}));
                }
                input.addClass('error-input');
                updateSubmitButton();
            };
            if ($input.hasClass('required') && !$input.is("input:password")) {
                const validate = () => {
                    if ($input.is("#email")) {
                        const validStr = () => {
                            const match = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
                            return $input.val().trim().length > 0 && match.test($input.val().trim());
                        };
                        const checkInUse = () => $.ajax({
                            url: '/users/check_email',
                            method: "POST",
                            dataType: "json",
                            data: { email: $input.val().trim() },
                            headers: { 
                                "X-CSRF-Token": $("meta[name='csrf-token']").attr("content") 
                            },
                        })
                        .done(() => setOk())
                        .fail((response) => {
                            if (response.status === 409) 
                                setInvalid($input, $label, "Email already in use.");
                            else {
                                setOk();
                                console.error("AJAX Error", response.status, response.responseText);
                            }
                        });
                        if (!validStr()) {
                            setInvalid($input, $label, "Please enter a valid email.");
                            return;
                        }
                        checkInUse();
                    } else {
                        const empty = !$input.val().trim();
                        if (empty) {
                            setInvalid($input, $label, " Required");
                        } else {
                            setOk();
                        }
                    }
                };
                $input.on('focusout', validate);
            }
            else if ($input.is("input:password") && $input.is("#password")) {
                const setConfirmEnabled = (enabled) => {
                    $("#password_confirm").prop('disabled', !enabled);
                };
                const strongPassword = (password) => (/^(?=.*\d).{9,}$/).test(password);
                const validate = () => {
                    const password = $input.val().trim();
                    const isStrong = strongPassword(password);
                    setConfirmEnabled(isStrong);
                    isStrong ? setOk() : setInvalid($input, $label, "Password must contain at least 8 characters and a digit.")
                };
                $input.on('input', validate);
            }
            else if ($input.is("input:password") && $input.is("#password_confirm")) {
                const password1 = $("#password").val().trim();
                const password2 = $("#password_confirm").val().trim();
                const passwordsMatch = (str1, str2) => {
                    return str1 === str2;
                };
                const validate = () => {
                    const p1 = $("#password").val().trim();
                    const p2 = $("#password_confirm").val().trim();
                    (p1 === p2 && p2.length > 0) ? setOk() : setInvalid($input, $label, "Passwords must match.");
                };
                $("#password").on('input', validate);
                $input.on("input", validate);
            }
        });
        $(document).on("input blur change", "input.required", updateSubmitButton);
        $('input[type="submit"][name="commit"]').prop('disabled', true);
    };
    validateRequiredFieldsSetup();
});