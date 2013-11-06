define([
    'app', 'dao/base', 'entities'
], function (App, Base, Entities) {
    'use strict';
    var API = {
        login: function (username, password) {
            var promise,
                user = new Entities.User();
            user.url = App.API_ROOT + '/user'; //
            promise = user.login(username, password);
            return promise;
        },
        logout: function () {
            // any instance of the User entity logs out the current user only
            return (new Entities.User()).logout();
        }
    };

    App.reqres.setHandler('user:login', function (username, password) {
        var promise = API.login(username, password);
        App.user = promise.user;
        return promise;
    });

    App.reqres.setHandler('user:logout', function () {
        return API.logout();
    });
});
