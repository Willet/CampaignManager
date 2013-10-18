define(["app", "marionette", 'jquery'], function (App, Marionette, $) {
    "use strict";
    var Login = Marionette.Layout.extend({
        template: "login",
        events: {
            "submit form": "login"
        },
        regions: {
            'loginFail': '.login-fail'
        },
        login: function (event) {
            var password, username, promise, self = this;
            event.preventDefault();

            username = $(event.target).find("[name='username']").val();
            password = $(event.target).find("[name='password']").val();

            promise = App.request("user:login", username, password);
            promise.fail(function () {
                self.$(self.loginFail.el).show();
            });
        },
        'onRender': function () {
            var self = this;
            this.$(this.loginFail.el).hide();
            setTimeout(function () {  // whenever the DOM shows this element
                self.$('#login-email').focus();
            }, 100);
        }
    });
    return Login;
});