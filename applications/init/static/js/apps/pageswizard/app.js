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

define(['app', 'exports', 'marionette', './views', 'views/main', 'entities', './controller'],
    function (App, PageWizard, Marionette, Views, MainViews, Entities) {
        PageWizard.Router = (function (_super) {

            __extends(Router, _super);

            function Router() {
                return Router.__super__.constructor.apply(this, arguments);
            }

            Router.prototype.appRoutes = {
                ":store_id/pages": "pagesIndex",
                ":store_id/pages/:id": "pagesName",
                ":store_id/pages/:id/layout": "pagesLayout",
                ":store_id/pages/:id/products": "pagesProducts",
                ":store_id/pages/:id/content": "pagesContent",
                ":store_id/pages/:id/view": "pagesView"
            };

            Router.prototype.triggers = {
                "click .js-next": "save"
            };

            Router.prototype.before = function (route, args) {
                var store, store_id;
                store_id = args[0];
                store = App.request("store:entity", store_id);
                App.execute("when:fetched", store, function () {
                    return App.nav.show(new MainViews.Nav({
                        model: new Entities.Model({
                            store: store,
                            page: 'pages'
                        })
                    }));
                });
                return this.controller.setRegion(App.main);
            };

            return Router;

        })(Marionette.AppRouter);
        App.addInitializer(function () {
            var controller, router;
            controller = new PageWizard.Controller();
            return router = new PageWizard.Router({
                controller: controller
            });
        });
        return PageWizard;
    });
