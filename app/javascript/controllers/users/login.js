document.addEventListener("turbo:load", function() {
    const required = [$("#username"), $("#password")];
    const empty = (item) => {
        return item.val().trim().length === 0;
    };
    required.forEach(function(item) {
        item.on("input blur", function() {
            $('input[type="submit"][name="commit"]').prop('disabled', 
                required
                .some((item) => empty(item))
            );
        });
    });
    $('input[type="submit"][name="commit"]').prop('disabled', true);
});