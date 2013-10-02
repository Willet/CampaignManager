require(["marionette", "jquery"], function (Marionette, $) {
    return _.extend(Backbone.Marionette.Application.prototype, {
        APP_ROOT: "/",
        navigate: function (route, options) {
            if (options == null) {
                options = {};
            }
            $(window).scrollTop(0);
            return Backbone.history.navigate(route, options);
        },
        getCurrentRoute: function () {
            var frag;
            frag = Backbone.history.fragment;
            if (_.isEmpty(frag)) {
                return null;
            } else {
                return frag;
            }
        },
        startHistory: function () {
            if (Backbone.history && !Backbone.history.start({
                pushState: true,
                root: this.APP_ROOT
            })) {
                return this.navigate("notFound", {
                    trigger: false
                });
            }
        },
        setTitle: function (title) {
            App.titlebar.currentView.model.set({
                title: title
            });
            return App.header.currentView.model.set({
                page: title
            });
        },
        show: function (view) {
            return this.main.show(view);
        }
    });
});
