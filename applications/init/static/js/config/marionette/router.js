// backbone.routefilter - v0.2.0 - 2013-02-16
// https://github.com/boazsender/backbone.routefilter
// Copyright (c) 2013 Boaz Sender; Licensed MIT
define(["backbone", "underscore"], function (Backbone, _) {
    var nop, originalRoute;
    originalRoute = Backbone.Router.prototype.route;
    nop = function () {
    };
    return _.extend(Backbone.Router.prototype, {
        before: nop,
        after: nop,
        initialize: function (options) {
            return this.controller = options['controller'];
        },
        route: function (route, name, callback) {
            var wrappedCallback;
            if (!callback) {
                callback = this[name];
            }
            wrappedCallback = _.bind(function () {
                var afterCallback, beforeCallback, callbackArgs;
                callbackArgs = [route, _.toArray(arguments)];
                beforeCallback = void 0;
                if (_.isFunction(this.before)) {
                    beforeCallback = this.before;
                } else if (typeof this.before[route] !== "undefined") {
                    beforeCallback = this.before[route];
                } else {
                    beforeCallback = nop;
                }
                if (beforeCallback.apply(this, callbackArgs) === false) {
                    return;
                }
                if (callback) {
                    callback.apply(this, arguments);
                }
                afterCallback = void 0;
                if (_.isFunction(this.after)) {
                    afterCallback = this.after;
                } else if (typeof this.after[route] !== "undefined") {
                    afterCallback = this.after[route];
                } else {
                    afterCallback = nop;
                }
                return afterCallback.apply(this, callbackArgs);
            }, this);
            return originalRoute.call(this, route, name, wrappedCallback);
        }
    });
});
