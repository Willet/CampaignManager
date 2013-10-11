define([
    "app", "entities/base", "entities/products"
], function (App, Base, Entities) {
    Entities = Entities || {};

    Entities.User = Base.Model.extend({
        login: function(username, password) {
            var that = this,
                login;

            login = $.ajax({
                url: this.url + '/login/', // trailing slash required for some reason
                contentType: "application/json",
                dataType: 'json',
                type: 'POST',
                crossDomain: true,
                data: JSON.stringify({
                    username: username,
                    password: password
                })
            });

            login.done(function(response) {
                // Iterate over all things in response,
                // and set properties on this model.
                that.set(response);

                // Is this where this belongs?
                // Why do we need to do this? Why can't we just use App?
                // Why is App not what I expect it to be?
                window.App.user = that;

                // Is this where this belongs?
                App.navigate('126/pages', {
                    trigger: true
                });
            });
        },

        logout: function() {
            $.ajax({
                url: this.url + '/logout/',
                contentType: "application/json",
                dataType: 'json',
                type: 'POST'
            })
        }
    });

    return Entities
});