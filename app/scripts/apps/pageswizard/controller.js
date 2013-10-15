define(['./app', 'backbone.projections', 'marionette', 'jquery', 'underscore', './views', 'components/views/content_list', 'entities'],
    function (PageWizard, BackboneProjections, Marionette, $, _, Views,
              ContentList, Entities) {
        /*
         Can we afford comments?
         */
        PageWizard.Controller = Marionette.Controller.extend({
            pagesIndex: function (store_id) {
                var all_models, pages, view,
                    _this = this;
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
                App.execute("when:fetched", pages, function () {
                    return all_models = _.clone(pages.models);
                });
                return this.region.show(view);
            },
            pagesName: function (store_id, page_id) {
                var layout, page, store,
                    _this = this;
                page = App.routeModels.get('page');
                store = App.routeModels.get('store');
                layout = new Views.PageCreateName({
                    model: page,
                    store: store
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
                    return _this.region.show(layout);
                });
            },
            pagesLayout: function (store_id, page_id) {
                var layout, page;
                page = App.routeModels.get('page');
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
                return this.region.show(layout);
            },
            pagesProducts: function (store_id, page_id) {
                var layout, page, products, scrapes,
                    _this = this;
                page = App.routeModels.get('page');
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
                return this.region.show(layout);
            },
            pagesContent: function (store_id, page_id) {
                var contents, layout, page,
                    _this = this;
                page = App.routeModels.get('page');
                contents = App.request("content:entities:paged", store_id,
                    page_id);
                layout = new Views.PageCreateContent({
                    model: page
                });
                contents.getNextPage();
                layout.on("render", function () {
                    return layout.contentList.show(ContentList.createView(contents,
                        {
                            page: true
                        }));
                });
                return this.region.show(layout);
            },
            pagesView: function (store_id, page_id) {
                var page;
                page = App.routeModels.get('page');
                return this.region.show(new Views.PagePreview({
                    model: page
                }));
            }
        });
        return PageWizard;
    });
