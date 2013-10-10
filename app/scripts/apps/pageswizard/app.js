define(['app', 'exports', 'marionette', './views', 'entities', './controller', 'components/views/main_layout', 'components/views/main_nav', 'components/views/title_bar'],
    function (App, PageWizard, Marionette, Views, Entities, Controller,
              MainLayout, MainNav, TitleBar) {
        PageWizard.Router = Marionette.AppRouter.extend({
            appRoutes: {
                ":store_id/pages": "pagesIndex",
                ":store_id/pages/:page_id": "pagesName",
                ":store_id/pages/:page_id/layout": "pagesLayout",
                ":store_id/pages/:page_id/products": "pagesProducts",
                ":store_id/pages/:page_id/content": "pagesContent",
                ":store_id/pages/:page_id/view": "pagesView"
            },
            setupModels: function (route, args) {
                this.setupRouteModels(route, args);
                this.store = App.routeModels.get('store');
                return this.page = App.routeModels.get('page');
            },
            parameterMap: function (route, args) {
                var i, match, matches, params, _i, _len;
                params = {};
                matches = route.match(/:[a-zA-Z_-]+/g);
                for (i = _i = 0, _len = matches.length; _i < _len; i = ++_i) {
                    match = matches[i];
                    params[match.replace(/^:/, '')] = args[i];
                }
                return params;
            },
            setupRouteModels: function (route, args) {
                var entityRequestName, i, match, matches, model, name, params, _i, _len;
                params = this.parameterMap(route, args);
                matches = route.match(/:[a-zA-Z_-]+/g);
                App.routeModels = App.routeModels || new Backbone.Model();
                for (i = _i = 0, _len = matches.length; _i < _len; i = ++_i) {
                    match = matches[i];
                    entityRequestName = this.paramNameMapping(match);
                    model = App.request(entityRequestName, params);
                    name = this.routeModelNameMapping(match);
                    App.routeModels.set(name, model);
                }
                return App.routeModels;
            },
            routeModelNameMapping: function (param_name) {
                switch (param_name) {
                case ":store_id":
                    return "store";
                case ":page_id":
                    return "page";
                default:
                    return param_name;
                }
            },
            paramNameMapping: function (param_name) {
                switch (param_name) {
                case ":store_id":
                    return "store:entity";
                case ":page_id":
                    return "page:entity";
                default:
                    return param_name;
                }
            },
            before: function (route, args) {
                App.currentController = this.controller;
                this.setupModels(route, args);
                this.setupMainLayout(route);
                return this.setupLayoutForRoute(route);
            },
            setupMainLayout: function () {
                var layout,
                    _this = this;
                layout = new MainLayout();
                layout.on("render", function () {
                    layout.nav.show(new MainNav({
                        model: new Entities.Model({
                            store: _this.store,
                            page: 'pages'
                        })
                    }));
                    return layout.titlebar.show(new TitleBar({
                        model: new Entities.Model()
                    }));
                });
                this.controller.setRegion(layout.content);
                App.layout.show(layout);
                return layout;
            },
            setupLayoutForRoute: function (route) {
                var layout;
                if (route.indexOf(":store_id/pages/:page_id") === 0) {
                    return layout = this.setupPageWizardLayout(route);
                }
            },
            setupPageWizardLayout: function (route) {
                var layout,
                    _this = this;
                this.page_wizard_layout = layout = new Views.PageWizardLayout();
                layout.on("render", function () {
                    var routeSuffix;
                    routeSuffix = route.substring(_.lastIndexOf(route,
                        '/')).replace(/^\//, '');
                    routeSuffix = routeSuffix === ":page_id" ? "name"
                        : routeSuffix;
                    return layout.header.show(new Views.PageHeader({
                        model: new Entities.Model({
                            page: routeSuffix
                        }),
                        store: _this.store,
                        page: _this.page
                    }));
                });
                this.controller.region.show(layout);
                this.controller.setRegion(layout.content);
                return this.page_wizard_layout;
            }
        });
        App.addInitializer(function () {
            var controller, router;
            controller = new PageWizard.Controller();
            return router = new PageWizard.Router({
                controller: controller
            });
        });
        return PageWizard;
    });
