define(['app', 'marionette'], function (App, Marionette) {
    'use strict';
    App.Views.ItemView = Marionette.ItemView.extend({
        serializeData: function() {
            if (this.model) {
                return this.model.viewJSON();
            }
            return {};
        }
    });
});