$(() => {
    $(document).on("click", (evt) => {
        const $profileDropdown = $("#profile-dropdown-menu");
        const $profileLink = $("#profile-link");
        if (!$profileDropdown.length || !$profileLink.length) return;
        if ($profileDropdown.attr('open')) {
            if (!$profileLink.has(evt.target).length) {
                $profileDropdown.removeAttr("open");
            }
        }
    });
});