var __hasProp = {}.hasOwnProperty,
    __extends = function (child, parent) {
        for (var key in parent) {
            if (__hasProp.call(parent, key)) {
                child[key] = parent[key];
            }
        }
        function ctor() {
            this.constructor = child;
        }

        ctor.prototype = parent.prototype;
        child.prototype = new ctor();
        child.__super__ = parent.prototype;
        return child;
    };

define(["app", "views/main", "entities"], function (App, MainViews, Entities) {
    var Controller, Main, Router;
    Main = App.module("Main");
    Router = (function (_super) {

        __extends(Router, _super);

        function Router() {
            return Router.__super__.constructor.apply(this, arguments);
        }

        Router.prototype.appRoutes = {
            "": "storeIndex",
            ":store_id": "storeShow"
        };

        return Router;

    })(Marionette.AppRouter);
    Controller = (function (_super) {

        __extends(Controller, _super);

        function Controller() {
            return Controller.__super__.constructor.apply(this, arguments);
        }

        Controller.prototype.root = function (opts) {
            return App.main.show(new MainViews.Index());
        };

        Controller.prototype.storeIndex = function () {
            var stores;
            stores = App.request("store:entities");
            return App.execute("when:fetched", stores, function () {
                App.setTitle("Stores");
                return App.main.show(new MainViews.Index({
                    model: stores
                }));
            });
        };

        Controller.prototype.storeShow = function (store_id) {
            return App.navigate("" + (Backbone.history.getFragment()) + "/pages",
                {
                    trigger: true,
                    replace: true
                });
        };

        Controller.prototype.notFound = function (opts) {
            App.main.show(new MainViews.NotFound());
            App.header.currentView.model.set({
                page: "notFound"
            });
            return App.titlebar.currentView.model.set({
                title: "404 - Page Not Found"
            });
        };

        return Controller;

    })(Marionette.Controller);
    App.addInitializer(function () {
        var controller, router;
        controller = new Controller();
        router = new Router({
            controller: controller
        });
        return App.titlebar.show(new MainViews.TitleBar({
            model: App.pageInfo
        }));
    });
    return Main;
});
