define(['app', 'marionette', 'underscore'], function (App, Marionette, _) {
    'use strict';

    _.extend(Marionette.View.prototype, {

        extractClassSuffix: function (el, prefix) {
            var result = el.attr('class').match(new RegExp(prefix + '-([a-zA-Z-_]+)'));
            if (result) {
                return result[1];
            }
            return null;
        },

        relayEvents: function (view, prefix) {
            var _this = this;
            this.listenTo(view, 'all', function() {
                var args = [].slice.call(arguments);
                if (prefix) {
                    args[0] = prefix + ':' + args[0];
                }
                args.splice(1, 0, view);

                Marionette.triggerMethod.apply(_this, args);
            });
        },

        stopRelayEvents: function (view) {
            this.stopListening(view);
        }

    });
});