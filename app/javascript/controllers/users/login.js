$(function() {
    console.log("Login script imported and ready...");
    const user = $("#username_field");
    const pass = $("#password_field");
    function updateLoginButton() {
        console.log("updating login button...");
        const anyUnfilled = (user.val().trim() === '' || pass.val().trim() === '');
        $("#login_button").prop("disabled", anyUnfilled);
    };
    user.on('input blur', updateLoginButton);
    pass.on('input blur', updateLoginButton);
    updateLoginButton();
});