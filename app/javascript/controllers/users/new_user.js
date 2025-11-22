$(() => {
    console.log("Setting up validation for required fields and validation for email.");
    const injectStyle = () => {
        $('<style id="js-style">').text(`
            .error-text { color:#ff0000; margin-right: 10px; font-style: italic; }
            .error-input { outline: 1px solid #ff0000; }
            .hint { display: inline; }
        `).appendTo('head');
    };
    injectStyle();
    const validateRequiredFieldsSetup = () => {
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
            const setOk = (input, label) => {
                label.find('.error-text').remove();
                input.removeClass("error-input");
            };
            const setInvalid = (input, label, message) => {
                if (!label.find(".error-text").length) {
                    label.append($('<span>', { class: "error-text", text: `${message}`}));
                }
                input.addClass('error-input');
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
                                setOk($input, $label);
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
                            setOk($input, $label);
                        }
                    }
                };
                updateSubmitButton();
                $input.on('focusout', validate);
            }
        });
    };
    validateRequiredFieldsSetup();
});
