define(["app", "marionette", 'jquery'], function (App, Marionette, $) {
    var Login;
    Login = Marionette.Layout.extend({
        template: "login",
        events: {
            "submit form": "login"
        },
        login: function (event) {
            var password, username, user;
            event.preventDefault();

            username = $(event.target).find("[name='username']").val();
            password = $(event.target).find("[name='password']").val();

            user = App.request("user:login", username, password);
        }
    });
    return Login;
});