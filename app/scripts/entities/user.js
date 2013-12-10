define([
    'app', 'entities/base', 'entities/products', 'underscore'
], function (App, Base, Entities, _) {
    'use strict';
    Entities = Entities || {};

    Entities.User = Base.Model.extend({
        /**
         * @returns {Promise}
         */
        login: function (username, password) {
            var that = this,
                login;

            // TODO: Need to address security concerns of sending PW as plaintext
            login = $.ajax({
                url: this.url + '/login/', // trailing slash required for some reason
                contentType: 'application/json',
                dataType: 'json',
                type: 'POST',
                crossDomain: true,
                data: JSON.stringify({
                    username: username,
                    password: password
                })
            });

            login.done(function (response) {
                var store, navigateUrl;

                that.set(response);

                store = _.first(that.get('stores'));

                // Is this where this belongs?
                // Why do we need to do this? Why can't we just use App?
                // Why is App not what I expect it to be?
                window.App.user = that;
                // Should we create a store instance?
                window.App.store = store;

                $.getJSON(App.API_ROOT + '/store/?slug=' + that.get('username'))
                    .done(function (data) {
                        if (data.results.length) {
                            // store id, e.g. 126
                            navigateUrl = data.results[0].id + '/pages';
                        } else {
                            // Default to store 38 (Gap) for now...
                            navigateUrl = '38/pages';
                        }
                        App.navigate(navigateUrl, {
                            trigger: true
                        });
                    });
            });

            // allow more deferreds to be set
            return login.promise();
        },

        logout: function () {
            return $.ajax({
                url: this.url + '/logout/',
                contentType: 'application/json',
                dataType: 'json',
                type: 'POST'
            }).promise();
        }
    });

    return Entities;
});
