define(['app', 'exports', 'backbone', 'marionette', './views', 'entities', './controller', 'components/views/main_layout', 'components/views/main_nav', 'components/views/title_bar', 'underscore'],
    function (App, PageManager, Backbone, Marionette, Views, Entities, Controller,
              MainLayout, MainNav, TitleBar, _) {
        'use strict';
        PageManager.Router = Marionette.AppRouter.extend({
            appRoutes: {
                ':store_id/pages': 'pagesIndex',
                ':store_id/pages/:page_id': 'pagesName',
                ':store_id/pages/:page_id/layout': 'pagesLayout',
                ':store_id/pages/:page_id/products': 'pagesProducts',
                ':store_id/pages/:page_id/content': 'pagesContent',
                ':store_id/pages/:page_id/view': 'pagesView',
                ':store_id/pages/:page_id/publish': 'publishView'
            },
            setupModels: function (route, args) {
                this.setupRouteModels(route, args);
                this.store = App.routeModels.get('store');
                this.page = App.routeModels.get('page');
            },
            parameterMap: function (route, args) {
                var i, match, matches, params, _i, _len;
                params = {};
                matches = route.match(/:[a-zA-Z_-]+/g);
                for (i = _i = 0, _len = matches.length; _i < _len; i = ++_i) {
                    match = matches[i];
                    params[match.replace(/^:/, '').replace(/-/,'_')] = args[i];
                }
                return params;
            },
            setupRouteModels: function (route, args) {
                var entityRequestName, i, match, matches, model, name, params, _i, _len;
                // params = e.g. {store_id: "38", page_id: "97"}
                params = this.parameterMap(route, args);

                // find what the route captures
                matches = route.match(/:[a-zA-Z_-]+/g);
                App.routeModels = App.routeModels || new Backbone.Model();

                for (i = _i = 0, _len = matches.length; _i < _len; i = ++_i) {
                    match = matches[i];  // e.g. ':store_id'

                    // e.g. turn capture into request name, e.g. 'store:entity'
                    entityRequestName = this.paramNameMapping(match);

                    // makes a request for the object, e.g. Store
                    model = App.request(entityRequestName, params);

                    // name = e.g. 'store'
                    name = this.routeModelNameMapping(match);

                    App.routeModels.set(name, model);
                }
                return App.routeModels;
            },
            routeModelNameMapping: function (paramName) {
                switch (paramName) {
                case ':store_id':
                    return 'store';
                case ':page_id':
                    return 'page';
                default:
                    return paramName;
                }
            },
            /**
             * Turns a "capture group" into its entity request name.
             * @param {string} paramName
             * @returns {*}
             */
            paramNameMapping: function (paramName) {
                switch (paramName) {
                case ':store_id':
                    return 'store:get';
                case ':page_id':
                    return 'page:get';
                default:
                    return paramName;
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
                layout.on('render', function () {
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
                if (route.indexOf(':store_id/pages/:page_id') === 0) {
                    layout = this.setupPageManagerLayout(route);
                }
            },
            setupPageManagerLayout: function (route) {
                var layout,
                    _this = this;
                this.pageManagerLayout = layout = new Views.PageManagerLayout();
                layout.on('render', function () {
                    var routeSuffix;
                    routeSuffix = route.substring(_.lastIndexOf(route, '/')).replace(/^\//, '');
                    routeSuffix = routeSuffix === ':page_id' ? 'name' : routeSuffix;
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
                return this.pageManagerLayout;
            }
        });
        App.addInitializer(function () {
            var controller, router;
            controller = new PageManager.Controller();
            router = new PageManager.Router({
                controller: controller
            });
        });
        return PageManager;
    });
