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
            var _submit = $("input[type='submit'][name='commit']");
            _submit.prop('disabled', true);
            var _required = $('input.required:text, input.required:password');
            
            function updateSubmit() {
                $(_submit).prop('disabled', validator.helpers.requiredUnfulfilled);
            }

            var validator = {
                helpers: {
                    requiredUnfulfilled: function() { return $(_required).filter('.error').length > 0; },
                    setInvalid: function(input, label, reason) {
                        $(label).addClass('error');
                        $(input).addClass('error');
                        const msg = $(label).find('span.error');
                        if (msg.length === 0) {
                            $(label).append($('<span>', { class: "error", text: reason }));
                        } else {
                            $(msg).text(reason);
                        }
                        console.warn("Invalid field received.");
                        updateSubmit();
                    },
                    setOK: function(input, label) {
                        $(label).removeClass("error");
                        $(input).removeClass('error');
                        $(label).find("span.error").remove();
                        console.log("Setting field to OK. ");
                        updateSubmit();
                    }
                },
                email: function(input, label) {
                    var _emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9]{2,}$/;
                    const val = $(input).val().trim();
                    function validStr() { return (val.length > 0 && _emailRegex.test(val)); }
                    if (!validStr()) {
                        validator.helpers.setInvalid(input, label, "Invalid email address.");
                        return;
                    }
                    $.ajax({
                        url: '/users/check_email',
                        method: "POST",
                        dataType: "json",
                        data: { email: val },
                        headers: { 'X-CSRF-Token': $("meta[name='csrf-token']").attr('content')},

                    })
                    .done(function(_data, _status, _xhr) {
                        validator.helpers.setOK(input, label);
                    })
                    .fail(function(xhr) {
                        if (xhr.status === 409) {
                            validator.helpers.setInvalid(input, label, "Email already in use.");
                        } else {
                            validator.helpers.setOK(input, label);
                        }
                    });
                },
                password: function(input, label) {
                    var _passwordRegex = /^(?=.*\d).{8,}$/;
                    var password_type = {
                        regular: function() {
                            function strong() {
                                return _passwordRegex.test($(input).val().trim());
                            }
                            if (strong()) {
                                validator.helpers.setOK(input, label);
                            } else {
                                validator.helpers.setInvalid(input, label, "Password must be 8+ characters and include a number.");
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
                        password_type.confirm();
                    } else {
                        password_type.regular();
                    }
                },
                other: function(input, label) {
                    if ($(input).val().trim().length === 0) {
                        validator.helpers.setInvalid(input, label, "This field is required.");
                    } else {
                        validator.helpers.setOK(input, label);
                    }
                },
            };

            function validate(input, label) {
                if (!$(input).hasClass('required')) return;
                if ($(input).is("#user_email")) {
                    validator.email(input, label);
                } else if ($(input).is("input:password")) {
                    validator.password(input, label);
                } else {
                    validator.other(input, label);
                }
            }
            $(".input-group-required").each(function() {
                var $group = $(this);
                var $input = $group.find("input[type='text'], input[type='password'], input[type='email']");
                var $label = $group.find('.required-label');
                $(this).on('focusout', function() {
                    validate($input, $label);
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