define([
    "app", "dao/base", "entities"
], function (App, Base, Entities) {
    var API = {
        login: function (username, password) {
            var promise,
                user = new Entities.User();
            user.url = App.API_ROOT + "/user"; //
            promise = user.login(username, password);
            return promise;
        },
        logout: function () {

        }
    };

    App.reqres.setHandler("user:login", function (username, password) {
        var promise = API.login(username, password);
        App.user = promise.user;
        return promise;
    });
});