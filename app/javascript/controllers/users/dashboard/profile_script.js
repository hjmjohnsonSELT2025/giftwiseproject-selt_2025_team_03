

$(function() {
    class ProfilePopup {
        #clickedState = false; 
        #template; 
        #profileButton; 
        #setupFailure = false;
        #$menu = null; #outsideHandler; #escHandler;
        constructor(templateID, profileButtonID) {
            // Template & Profile button retrieval 
            this.#template = $(`#${templateID}`);
            this.#profileButton = $(`#${profileButtonID}`);
            if (this.#template)
            // Make sure they're found
            if (this.#template === undefined || this.#profileButton === undefined || this.#template.length === 0 || this.#profileButton.length === 0) {
                console.debug(
                    `Error finding ` + 
                    `${this.#template.length === 0 ? `template w/ ID ${templateID} ` : ""}` +
                    `${this.#profileButton.length === 0 ? `profile button w/ ID ${profileButtonID}` : ""}`
                );
                this.#setupFailure = true;
                return;
            }
            this.#profileButton.on("click", (e) => {
                e.preventDefault();
                e.stopPropagation();
                this.toggle();
            });
            $(window).on("resize.profilePopup scroll.profilePopup", () => this.#position());
        }
        toggle() {
            this.#clickedState ? this.hide() : this.show(); 
        }
        show() {
            if (this.#setupFailure || this.#$menu) return;
            const cloned = this.#template[0];
            let fragment;
            if (cloned && cloned.content) {
                fragment = cloned.content.cloneNode(true);
            } else {
                fragment = document.createDocumentFragment();
                $(this.#template.html()).appendTo(fragment);
            }
            const element = $(fragment).children().first();
            this.#$menu = $(element)
                .attr("role", "menu")
                .attr("tabindex", "-1")
                .css({
                    position: "absolute",
                    zIndex: 9999,
                    minWidth: this.#profileButton.outerWidth()
                })
                .appendTo(document.body);
            this.#position();
            this.#clickedState = true;
            // Close on outside click or escape
            this.#outsideHandler = (evt) => {
                const $target = $(evt.target);
                if (!$target.closest(this.#$menu).length && !$target.closest(this.#profileButton).length ) {
                    this.hide();
                }
            };
            this.#escHandler = (evt) => { 
                if (evt.key === 'Escape') this.hide();
            };
            $(document).on('click.profilePopup', this.#outsideHandler);
            $(document).on('keydown.profilePopup', this.#escHandler);

            setTimeout(() => this.#$menu && this.#$menu.focus(), 0);

        }
        #position() {
            if (!this.#$menu) return;
            const buttonOffset = this.#profileButton.offset();
            const top = buttonOffset.top + this.#profileButton.outerHeight() + 8;
            let left = buttonOffset.left + this.#profileButton.outerWidth() - this.#$menu.outerWidth();
            left = Math.max(8, Math.min(left, $(window).scrollLeft() + $(window).width() - this.#$menu.outerWidth() - 8));

            this.#$menu.css({ top, left});
        }
        hide() {
            if (!this.#$menu) return;
            $(document).off('click.profilePopup', this.#outsideHandler);
            $(document).off('keydown.profilePopup', this.#escHandler);
            this.#$menu.remove();
            this.#$menu = null;
            this.#clickedState = false;
        }
        destroy() {
            this.hide();
            this.#profileButton.off("click");
            $(window).off('resize.profilePopup scroll.profilePopup');
        }
    };
    new ProfilePopup("profile-popup", "profile-link");
});