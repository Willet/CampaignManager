define(['./app', 'backbone.projections', 'marionette', 'jquery', 'underscore', './views', 'components/views/content_list', 'entities'],
    function (PageWizard, BackboneProjections, Marionette, $, _, Views,
              ContentList, Entities) {
        'use strict';

        PageWizard.Controller = Marionette.Controller.extend({
            pagesIndex: function (store_id) {
                var all_models, pages, store, view,
                    _this = this;

                // gets a list of pages belonging to this store.
                pages = App.request("page:entities", store_id);
                store = App.request("store:entity", {store_id: store_id});
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
                    page.set('layout', newLayout);
                    return layout.render();
                });
                layout.on('save', function () {
                    _.each(layout.getFields(), function (v, k) {
                        // content graph 500s on you if you PATCH with an
                        // empty string (something about dynamos).
                        // setting it to null removes the value from the DB.
                        if (v === '') {
                            v = null;
                        }
                        page.set(k, v);
                    });
                    return $.when(page.save())
                        .done(function (data) {
                            // TODO: Should we only do this when page_id === 'new'?
                            var store = data['store-id'],
                                page = data['id'];

                            return App.navigate("/" + store + "/pages/" + page + "/products",
                                {
                                    trigger: true
                                });
                        }).fail(function (jqXHR, why) {
                            console.log(arguments);
                        });
                });
                return this.region.show(layout);
            },
            pagesProducts: function (store_id, page_id) {
                var layout, page, products, scrapes, product_list,
                    _this = this;
                page = App.routeModels.get('page');
                scrapes = App.request("page:scrapes:entities", store_id, page_id);
                products = App.request("product:entities:paged", store_id, page_id);
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
                        scrape.save();
                        // TODO: remove dirty hack that just queues it and hopes
                        //       for the best; backend has no way to check status
                        //       right now???
                        $.ajax(
                            "http://scraper-test.elasticbeanstalk.com/scrapers/queue/store/#{store_id}/?url=#{url}"
                        );
                    });
                    return scrapeList.on("itemview:remove", function (view) {
                        return scrapes.remove(view.model);
                    });
                });
                layout.on('added-product', function (product_data) {
                    var new_product = new Entities.Product(product_data);
                    // TODO: we should really only add this in the case
                    //       the products is of type 'added'
                    products.add(new_product);
                });
                product_list = new Views.PageProductList({collection: products, added: false});
                layout.on('display:needs-review', function() {
                    products = App.request("product:entities:paged", store_id, page_id);
                    product_list = new Views.PageProductList({collection: products, added: false});
                    layout.productList.show(product_list);
                });
                layout.on('display:added-to-page', function() {
                    products = App.request("added-to-page:product:entities:paged", store_id, page_id);
                    product_list = new Views.PageProductList({collection: products, added: true});
                    layout.productList.show(product_list);
                });
                layout.on('render', function () {
                    layout.productList.show(product_list);
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
                var contents, content_list, layout, page,
                    _this = this;
                page = App.routeModels.get('page');
                contents = App.request("content:entities:paged", store_id, page_id);
                content_list = ContentList.createView(contents, { page: true });
                layout = new Views.PageCreateContent({
                    model: page
                });
                layout.on('display:needs-review', function() {
                    contents = App.request("content:entities:paged", store_id, page_id);
                    content_list = ContentList.createView(contents, { page: true });
                    layout.contentList.show(content_list);
                });
                layout.on('display:added-to-page', function() {
                    contents = App.request("added-to-page:content:entities:paged", store_id, page_id);
                    content_list = ContentList.createView(contents, { page: true });
                    layout.contentList.show(content_list);
                });
                layout.on("render", function () {
                    layout.contentList.show(content_list);
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
                // existence of bucket name is a signal that the page was
                // successfully created.

                var page = App.routeModels.get('page'),
                    store = App.routeModels.get('store'),
                    self = this,
                    args = arguments,
                    getBucketInfo = function (page, store) {
                        // mock out page generator result, making sure
                        // that the urls match CM's format
                        var domain = store.get('public-base-url')
                                .replace(/https?:\/\//i, '')
                                .replace(/\/$/, ''),
                            path = page.get('url');
                        if (path.substring(0, 1) === '/') {
                            path = path.substring(1);
                        }
                        if (path.substring(0, 1) === '/') {
                            path = path.substring(1);
                        }

                        if (App.ENVIRONMENT === 'DEV') {
                            domain = 'dev-' + domain;
                        } else if (App.ENVIRONMENT === 'TEST') {
                            domain = 'test-' + domain;
                        }

                        return {
                            'result': {
                                'bucket_name': domain,
                                's3_path': path
                            },
                            'url': 'http://' + domain + '/' + path
                        };
                    };

                return App.execute("when:fetched", page, function () {
                    return App.execute("when:fetched", store, function () {
                        $.ajax(data || getBucketInfo(page, store))
                            .done(function () {
                                var view = new Views.PagePreview({
                                    model: new Entities.Model(data)
                                });
                                return self.region.show(view);
                            })
                            .fail(function () {
                                // S3 emits 404 if page not generated
                                return self.generateView.apply(self, args);
                            });
                    });
                });
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

                    // TODO: less fugly handler
                    layout.$('.generate.button').text("Generating...");

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

                        if (App.ENVIRONMENT === 'DEV') {
                            store.set(
                                'public-base-url',
                                store.get('public-base-url', '')
                                    .replace(/(https?:\/\/)/, '$1dev-')
                            );
                        } else if (App.ENVIRONMENT === 'TEST') {
                            store.set(
                                'public-base-url',
                                store.get('public-base-url', '')
                                    .replace(/(https?:\/\/)/, '$1test-')
                            );
                        }

                        return self.region.show(layout);
                    });
                });
            }
        });
        return PageWizard;
    });
