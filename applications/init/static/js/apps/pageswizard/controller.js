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

define(['./app', 'backboneprojections', 'marionette', 'jquery', 'underscore', './views', '../contentmanager/views', 'views/main', 'components/views/content_list', 'entities', './views/index', './views/content', './views/layout', './views/name', './views/products'],
    function (PageWizard, BackboneProjections, Marionette, $, _, Views,
              ContentViews, MainViews, ContentList, Entities) {
        PageWizard.Controller = (function (_super) {

            __extends(Controller, _super);

            function Controller() {
                return Controller.__super__.constructor.apply(this, arguments);
            }

            Controller.prototype.pagesIndex = function (store_id) {
                var all_models, pages, view,
                    _this = this;
                this.page = null;
                pages = App.request("page:entities", store_id);
                view = new Views.PageIndex({
                    model: pages,
                    'store-id': store_id
                });
                all_models = null;
                view.on('change:filter', function (filter) {
                    var filtered_pages;
                    filtered_pages = _.filter(all_models, function (m) {
                        return (m.get("name") || "").search(filter) !== -1;
                    });
                    return pages.reset(filtered_pages);
                });
                view.on('change:sort-order', function (order) {
                    return pages.updateSortBy(order,
                        order === 'last-modified');
                });
                view.on('edit-most-recent', function () {
                    var most_recent;
                    most_recent = _.max(all_models, function (m) {
                        return m.get('last-modified');
                    });
                    return App.navigate("/" + store_id + "/pages/" + most_recent.id,
                        {
                            trigger: true
                        });
                });
                view.on('new-page', function () {
                    return App.navigate("/" + store_id + "/pages/new", {
                        trigger: true
                    });
                });
                return App.execute("when:fetched", pages, function () {
                    all_models = _.clone(pages.models);
                    _this.region.show(view);
                    return App.setTitle("Pages");
                });
            };

            Controller.prototype.getPage = function (store_id, page_id) {
                return this.page = page_id === "new"
                    ? this.page && this.page.get('id') === null ? this.page
                                       : this.page = App.request("new:page:entity",
                    store_id) : this.page && this.page.get('id') === page_id
                                       ? this.page : App.request("page:entity",
                    store_id, page_id);
            };

            Controller.prototype.pagesName = function (store_id, page_id) {
                var layout, page,
                    _this = this;
                page = this.getPage(store_id, page_id);
                layout = new Views.PageCreateName({
                    model: page
                });
                layout.on('save', function () {
                    return $.when(page.save()).done(function () {
                        return App.navigate("/" + store_id + "/pages/" + page_id + "/content",
                            {
                                trigger: true
                            });
                    });
                });
                return App.execute("when:fetched", page, function () {
                    _this.region.show(layout);
                    return App.setTitle(page.get("name"));
                });
            };

            Controller.prototype.pagesLayout = function (store_id, page_id) {
                var layout, page,
                    _this = this;
                page = this.getPage(store_id, page_id);
                layout = new Views.PageCreateLayout({
                    model: page
                });
                layout.on('layout:selected', function (newLayout) {
                    page.set("layout", newLayout);
                    return layout.render();
                });
                layout.on('save', function () {
                    page.set('fields', layout.getFields());
                    return $.when(page.save()).done(function () {
                        return App.navigate("/" + store_id + "/pages/" + page_id + "/products",
                            {
                                trigger: true
                            });
                    });
                });
                return App.execute("when:fetched", page, function () {
                    _this.region.show(layout);
                    return App.setTitle(page.get("name"));
                });
            };

            Controller.prototype.pagesProducts = function (store_id, page_id) {
                var layout, page, products, scrapes,
                    _this = this;
                page = this.getPage(store_id, page_id);
                scrapes = App.request("page:scrapes:entities", store_id,
                    page_id);
                products = new Entities.ContentCollection;
                layout = new Views.PageCreateProducts({
                    model: page
                });
                layout.on("show", function () {
                    var scrapeList;
                    scrapeList = new Views.PageScrapeList({
                        collection: scrapes
                    });
                    layout.scrapeList.show(scrapeList);
                    layout.on("new:scrape", function (url) {
                        var scrape;
                        scrape = new Entities.Scrape({
                            store_id: store_id,
                            page_id: page_id,
                            url: url
                        });
                        scrapes.add(scrape);
                        return scrape.save();
                    });
                    return scrapeList.on("itemview:remove", function (view) {
                        return scrapes.remove(view.model);
                    });
                });
                layout.on('save', function () {
                    return $.when(page.save()).done(function () {
                        return App.navigate("/" + store_id + "/pages/" + page_id + "/content",
                            {
                                trigger: true
                            });
                    });
                });
                return App.execute("when:fetched", page, function () {
                    App.show(layout);
                    return App.setTitle(page.get("name"));
                });
            };

            Controller.prototype.pagesContent = function (store_id, page_id) {
                var contents, layout, page,
                    _this = this;
                page = this.getPage(store_id, page_id);
                contents = App.request("content:entities:paged", store_id,
                    page_id);
                layout = new Views.PageCreateContent({
                    model: page
                });
                contents.getNextPage();
                return App.execute("when:fetched", [page, contents],
                    function () {
                        layout.on("show", function () {
                            return layout.contentList.show(ContentList.createView(contents,
                                {
                                    page: true
                                }));
                        });
                        App.show(layout);
                        return App.setTitle(page.get("name"));
                    });
            };

            Controller.prototype.pagesView = function (store_id, page_id) {
                var page,
                    _this = this;
                page = App.request("page:entity", store_id, page_id);
                return App.execute("when:fetched", page, function () {
                    App.show(new Views.PagePreview({
                        model: page
                    }));
                    return App.setTitle(page.get("name"));
                });
            };

            return Controller;

        })(Marionette.Controller);
        return PageWizard;
    });
