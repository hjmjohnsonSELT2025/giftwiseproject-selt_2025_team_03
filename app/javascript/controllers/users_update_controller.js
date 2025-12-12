import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        function after(delay, func) {
            let t;
            return function(...args) {
                const c = this;
                clearTimeout(t);
                t = setTimeout(function() {
                    func.apply(c, args);
                }, delay);
            };
        }
        function setupValidations() {
            var submit = $("input[type='submit'][name='commit']");
            var req = $("input.required:password");
            var validator = {
                helpers: {
                    requiredUnfulfilled: function() {
                        return $(req).filter(".error").length > 0;
                    },
                    setInvalid: function(input, label, reason) {
                        $(label).addClass('error');
                        $(input).addClass('error');
                        const msg = $(label).find('span.error');
                        if (msg.length === 0) {
                            $(label).append($('<span>', { class: 'error', text: reason}));
                        } else {
                            $(msg).text(reason);
                        }
                        console.warn("Invalid field received");
                        updateSubmit();
                    },
                    setOK: function(input, label) {
                        $(label).removeClass('error');
                        $(input).removeClass('error');
                        $(label).find("span.error").remove();
                        console.log("Settingn field to OK.");
                        updateSubmit();
                    },
                },
                password: function(input, label) {
                    var _regex = /^(?=.*\d).{8,}$/;
                    var type = {
                        regular: function() {
                            function strong() {
                                return _regex.text($(input).val().trim());
                            }
                            const val = $(input).val().trim();
                            if (strong()) {
                                validator.helpers.setOK(input, label);
                            } else if (val.length === 0) { /* empty. when updating, this doesn't matter. */}
                            else {
                                validator.helpers.setInvalid(
                                    input, label, 'Password must be 8+ characters and contain a digit.'
                                );
                            }
                        },
                        confirm: function() {
                            if ($(input).val().trim() !== $("#user_password").val().trim()) {
                                validator.helpers.setInvalid(input, label, "Passwords must match.");
                            } else {
                                validator.helpers.setOK(input, label);
                            }
                        },
                    };
                    if ($(input).is("#user_password_confirm")) {
                        type.confirm();
                    } else {
                        type.regular();
                    }
                },
            };
            function updateSubmit() {
                var errors = validator.helpers.requiredUnfulfilled();

                $(submit).prop("disabled", errors);
            }
            updateSubmit();
            function validate(input, label) {
                if ($(input).is("input:password")) {
                    validator.password(input, label);
                }
            }
            $(".input-group-required").each(function() {
                var group = $(this);
                var input = group.find("input[type='password']");
                var label = group.find(".required-label");
                group.on('focusout', function() {
                    validate(input, label);
                });
            });
        }
        function setupFieldCounters() {
            var limitedFields = [
                {
                    field: $("#interests-field"),
                    counter: $("#interests-counter"),
                },
                {
                    field: $("#aversions-field"),
                    counter: $("#aversions-counter"),
                },
            ];
            limitedFields.forEach((item) => {
                $(item.field).on("input", function() {
                    $(item.counter).text(`${item.field.val().length}`);
                    console.log(item.field.val().length);
                });
            });
        }
        setupFieldCounters();
        setupValidations();
    }
}