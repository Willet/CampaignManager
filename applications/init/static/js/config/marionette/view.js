require(["marionette"], function (Marionette) {
    return _.extend(Backbone.Marionette.View.prototype, {
        extractClassSuffix: function (el, prefix) {
            var result;
            if (result = el.attr('class').match(new RegExp("" + prefix + "-([a-zA-Z-_]+)"))) {
                return result[1];
            }
        },
        relayEvents: function (view, prefix) {
            var _this = this;
            return this.listenTo(view, "all", function () {
                var args;
                args = [].slice.call(arguments);
                if (prefix) {
                    args[0] = prefix + ":" + args[0];
                }
                args.splice(1, 0, view);
                return Marionette.triggerMethod.apply(_this, args);
            });
        }
    });
});
