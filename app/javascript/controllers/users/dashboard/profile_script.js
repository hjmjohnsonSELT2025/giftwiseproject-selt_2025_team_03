$(() => {
    const $profileDropdown = $("#profile-dropdown-menu");
    const $profileLink = $("#profile-link");
    if (!$profileDropdown.length || !$profileLink.length) return;
    $(document).on("click", (evt) => {
        if ($profileDropdown.attr('open')) {
            if (!$profileLink.has(evt.target).length) {
                $profileDropdown.removeAttr("open");
            }
        }
        evt.bubbles = true;
    });
    
});