define([
    "app", "dao/base", "entities"
], function (App, Base, Entities) {
    var API = {
        login: function (username, password) {
            var info,
                user = new Entities.User();
            user.url = App.API_ROOT + "/user"; //
            info = user.login(username, password);
            return info;
        },
        logout: function () {

        }
    };

    App.reqres.setHandler("user:login", function (username, password) {
        var info = API.login(username, password);
        App.user = info.user;
        return info;
    });
});