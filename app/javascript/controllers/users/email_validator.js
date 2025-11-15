console.log("email_validator.js loaded");

const validate_email = () => {
    const fields = $(".email-field-container");
    const valid_email_str = (str) => {
        const match = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        return match.test(str);
    }

    fields.each(function() {
        const emailField = $(this).find(".email-field");
        const info = $(this).find(".email-info");
        const onOk = () => {
            console.log("received ok from server");
            info.removeClass("warn").addClass("ok");
            info.text("Email available.");
            console.log("onOk text now:", info.text());
        };
        const onFail = (response) => {
            console.log("received failure from server.");
            info.removeClass("ok").addClass("warn");
            if (response.status === 409) info.text("Email is already in use.");
            else {
                info.text("Server error.");
                console.log(`${response}`)
            }
            console.log("onFail text now:", info.text());
        };
        emailField.on("focusout", () => {
            console.log("verifying email...");
            if (valid_email_str(emailField.val())) {
                console.log("valid email string. sending xhr request to server.");
                $.ajax({
                    url: "check_email",
                    method: "POST",
                    dataType: "json",
                    data: {
                        email: emailField.val()
                    },
                    headers: {
                        "X-CSRF-Token": $("meta[name='csrf-token']").attr("content")
                    },
                    success: onOk,
                    error: onFail
                });
            } else {
                console.log("invalid email.");
                info.removeClass("ok").addClass("warn");
                info.text("Please enter a valid email address.");
            }
        });
    });
}

$(document).ready(() => {
    validate_email();
});