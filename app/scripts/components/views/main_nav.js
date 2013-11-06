define(['marionette'], function (Marionette) {
    'use strict';
    var MainNav = Marionette.ItemView.extend({
        template: 'shared/nav',
        events: {
            'click .logout': 'logout'
        },
        initialize: function () {
            var self = this,
                ref = this.model.get('store');
            if (ref !== null) {
                return ref.on('sync', function () {
                    return self.render();
                });
            }
        },
        serializeData: function () {
            var json = {};
            if (this.model.get('store')) {
                json.store = this.model.get('store').toJSON();
            }
            json.page = this.model.get('page');
            return json;
        }
    });
    return MainNav;
});
