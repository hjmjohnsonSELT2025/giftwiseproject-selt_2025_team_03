$(function() {
    const updateSubmitButton = () => {
        const allInfos = $(".required .info");
        const anyInvalid = allInfos.filter(":not(.ok)").length > 0;
        $("#create_account_button").prop("disabled", anyInvalid);
    };
    const requiredFields = $(".required");
    //const fieldMatch = /^[a-zA-Z]+$/;     // maybe not chekc this for now
    requiredFields.each(function() {
        const input = $(this).find('.input');
        const info = $(this).find('.info');
        if (!input.is("#email_field_input")) {
            input.on('input blur', () => {
                if (!input.val()) {
                    info.removeClass("ok").addClass("warn");
                    info.text("This field is required.");
                } else {
                    info.removeClass("warn").addClass("ok");
                    info.text("");
                }
                updateSubmitButton();
            });
        }
    });
});