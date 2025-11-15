
/* Assumes parental '.required' div wrapper
* */
const make_required_fields = () => {
    const fields = $(".required");
    const submit = $("#create_account_button");
    const requiredFieldsFilled = () => {
        let allFilled = true;
        fields.each(function() {
            const text = $(this).find($('input[type="text"]'));
            if (text.val().empty()) allFilled = false;
        });
        return allFilled;
    }
    fields.each(function() {
        const textField = $(this).find($('input[type=text]'));
        const labelPlaceholder = $(this).find($('.info'));

        textField.on('input change', () => {
            if (requiredFieldsFilled()) submit.enable();
            else submit.disable();
            if (textField.val().empty()) {
                labelPlaceholder.text("Required field.");
            } else {
                labelPlaceholder.text("");
            }
        });

    })
}