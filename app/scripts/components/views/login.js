define(["app", "marionette", 'jquery'], function (App, Marionette, $) {
    var Login;
    Login = Marionette.Layout.extend({
        template: "login",
        events: {
            "submit form": function (event) {
                return this.login(event);
            }
        },
        login: function (event) {
            var password, username;
            event.preventDefault();
            username = $(event.target).find("[name='username']").val();
            password = $(event.target).find("[name='password']").val();
            return $.ajax({
                url: App.API_ROOT + '/user/login/',
                contentType: "application/json",
                dataType: 'json',
                type: 'POST',
                crossDomain: true,
                data: JSON.stringify({
                    username: username,
                    password: password
                }),
                success: function () {
                    return App.navigate('126/pages', {
                        trigger: true
                    });
                }
            });
        }
    });
    return Login;
});