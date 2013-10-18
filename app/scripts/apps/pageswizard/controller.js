define(['./app', 'backbone.projections', 'marionette', 'jquery', 'underscore', './views', 'components/views/content_list', 'entities'],
    function (PageWizard, BackboneProjections, Marionette, $, _, Views,
              ContentList, Entities) {
        "use strict";

        PageWizard.Controller = Marionette.Controller.extend({
            pagesIndex: function (store_id) {
                var all_models, pages, store, view,
                    _this = this;

                // gets a list of pages belonging to this store.
                pages = App.request("page:entities", store_id);
                store = App.request("store:entity", store_id);
                view = new Views.PageIndex({
                    model: pages,
                    'store': store
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
                    App.execute("when:fetched", store, function () {
                        return all_models = _.clone(pages.models);
                    });
                });
                return this.region.show(view);
            },
            pagesName: function (store_id, page_id) {
                var layout, page, store,
                    self = this;
                page = App.routeModels.get('page');
                store = App.routeModels.get('store');
                layout = new Views.PageCreateName({
                    model: page,
                    store: store
                });
                layout.on('save', function () {
                    return $.when(page.save()).done(function (data) {
                        // TODO: Should we only do this when page_id === 'new'?
                        var store = data['store-id'],
                            page = data['id'];

                        return App.navigate("/" + store + "/pages/" + page + "/layout",
                            {
                                trigger: true
                            });
                    });
                });
                return App.execute("when:fetched", page, function () {
                    return self.region.show(layout);
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
                    return $.when(page.save()).done(function (data) {
                        // TODO: Should we only do this when page_id === 'new'?
                        var store = data['store-id'],
                            page = data['id'];

                        return App.navigate("/" + store + "/pages/" + page + "/products",
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
                    return $.when(page.save()).done(function (data) {
                        // TODO: Should we only do this when page_id === 'new'?
                        var store = data['store-id'],
                            page = data['id'];

                        return App.navigate("/" + store + "/pages/" + page + "/content",
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

                layout.on('save', function () {
                    return $.when(page.save()).done(function (data) {
                        // TODO: Should we only do this when page_id === 'new'?
                        var store = data['store-id'],
                            page = data['id'];

                        return App.navigate("/" + store + "/pages/" + page + "/generate",
                            {
                                trigger: true
                            });
                    });
                });

                return this.region.show(layout);
            },
            /**
             * Shows in iframe with the page in it.
             */
            pagesView: function (store_id, page_id, data) {
                var view = new Views.PagePreview({
                    model: new Entities.Model(data)
                });
                view.on('generate', function () {
                    return App.navigate(
                        "/" + store_id + "/pages/" + page_id + "/generate",
                        {trigger: true}
                    );
                });
                return this.region.show(view);
            },
            generateView: function (store_id, page_id) {
                var page, store, layout, self = this;
                page = App.routeModels.get('page');
                store = App.routeModels.get('store');

                layout = new Views.GeneratePage({
                    model: page,
                    store: store
                });
                layout.on("generate", function () {
                    // TODO: move static_pages API under /graph/v1. ain't nobody got time for that today
                    var req, base_url = App.API_ROOT
                        .replace("/graph/v1", '/static_pages')
                        .replace(":9000", ':8000');

                    // TODO: handle case where page_id is 'new'

                    req = $.ajax({
                        url: base_url + '/' + store_id + '/' + page_id + '/regenerate',
                        type: 'POST',
                        dataType: 'jsonp'
                    });
                    req.done(function (data, status, request) {
                        // crude as it is, this is also an option
                        // window.open('http://' + data.result.bucket_name + '/' +
                        //     data.result.s3_path);
                        self.pagesView(store_id, page_id, data);
                    });
                    req.fail(function (request, status, error) {
                        // TODO: What to do on fail?
                    });
                });

                return App.execute("when:fetched", page, function () {
                    return App.execute("when:fetched", store, function () {
                        return self.region.show(layout);
                    });
                });
            }
        });
        return PageWizard;
    });
