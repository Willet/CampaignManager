define([
    "app", "dao/base", "entities"
], function (App, Base, Entities) {
    var API = {
        login: function (username, password) {
            var user = new Entities.User();
            user.url = App.API_ROOT + "/user"; //
            user.login(username, password);
            return user;
        },
        logout: function () {

        }
    };

    App.reqres.setHandler("user:login", function (username, password) {
        var user = API.login(username, password);
        App.user = user;
    });
});