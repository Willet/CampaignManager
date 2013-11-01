define(['app', './app', 'backbone.projections', 'marionette', 'jquery', 'underscore', './views', 'components/views/content_list', 'entities'],
    function (App, PageWizard, BackboneProjections, Marionette, $, _, Views,
              ContentList, Entities) {
        'use strict';

        PageWizard.Controller = Marionette.Controller.extend({
            pagesIndex: function (storeId) {
                var allModels, pages, store, view;

                // gets a list of pages belonging to this store.
                pages = App.request('page:entities', storeId);
                store = App.request('store:entity', {'store_id': storeId});
                view = new Views.PageIndex({
                    model: pages,
                    'store': store
                });
                allModels = null;
                view.on('change:filter', function (filter) {
                    var filteredPages = _.filter(allModels, function (m) {
                        return new RegExp(filter, 'i').test(m.get('name') || '');
                    });
                    return pages.reset(filteredPages);
                });
                view.on('change:sort-order', function (order) {
                    return pages.updateSortBy(order,
                        order === 'last-modified');
                });
                view.on('edit-most-recent', function () {
                    var mostRecent = _.max(allModels, function (m) {
                        return m.get('last-modified');
                    });
                    return App.navigate('/' + storeId + '/pages/' + mostRecent.id,
                        {
                            trigger: true
                        });
                });
                view.on('new-page', function () {
                    return App.navigate('/' + storeId + '/pages/new', {
                        trigger: true
                    });
                });
                App.execute('when:fetched', pages, function () {
                    App.execute('when:fetched', store, function () {
                        allModels = _.clone(pages.models);
                        return allModels;
                    });
                });
                return this.region.show(view);
            },
            pagesName: function () {
                var layout, page, store,
                    self = this;
                page = App.routeModels.get('page');
                store = App.routeModels.get('store');
                layout = new Views.PageCreateName({
                    model: page,
                    store: store
                });
                layout.on('save', function () {
                    $.when(page.save()).done(function (data) {
                        // TODO: Should we only do this when pageId === 'new'?
                        var store = data['store-id'],
                            page = data.id;

                        App.navigate('/' + store + '/pages/' + page + '/layout',
                            {
                                trigger: true
                            });
                    });
                });
                App.execute('when:fetched', page, function () {
                    App.execute('when:fetched', store, function () {
                        self.region.show(layout);
                    });
                });
            },
            pagesLayout: function () {
                var layout, page;
                page = App.routeModels.get('page');
                layout = new Views.PageCreateLayout({
                    model: page
                });
                layout.on('layout:selected', function (newLayout) {
                    page.set('layout', newLayout);
                    layout.render();
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
                    $.when(page.save())
                        .done(function (data) {
                            // TODO: Should we only do this when pageId === 'new'?
                            var store = data['store-id'],
                                page = data.id;

                            App.navigate('/' + store + '/pages/' + page + '/products',
                                {
                                    trigger: true
                                });
                        }).fail(function () {
                            console.log(arguments);
                        });
                });
                this.region.show(layout);
            },
            pagesProducts: function (storeId, pageId) {
                var layout, page, products, scrapes, productList;
                page = App.routeModels.get('page');
                scrapes = App.request('page:scrapes:entities', storeId, pageId);
                products = App.request('product:entities:paged', storeId, pageId);

                App.execute('when:fetched', products, function() {
                    // for each product, fetch their content image
                    products.collect(function(product) {
                        App.request('fetch:content', storeId, product.get('default-image-id'));
                    });
                });


                layout = new Views.PageCreateProducts({
                    model: page
                });
                layout.on('show', function () {
                    var scrapeList;
                    scrapeList = new Views.PageScrapeList({
                        collection: scrapes
                    });
                    layout.scrapeList.show(scrapeList);
                    layout.on('new:scrape', function (url) {
                        var scrape;
                        scrape = new Entities.Scrape({
                            'store_id': storeId,
                            'page_id': pageId,
                            'url': url
                        });
                        scrapes.add(scrape);
                        scrape.save();
                        // TODO: remove dirty hack that just queues it and hopes
                        //       for the best; backend has no way to check status
                        //       right now???
                        $.ajax(
                            'http://scraper-test.elasticbeanstalk.com/scrapers/queue/store/#{storeId}/?url=#{url}'
                        );
                    });
                    scrapeList.on('itemview:remove', function (view) {
                        scrapes.remove(view.model);
                    });
                });
                layout.on('added-product', function (productData) {
                    var newProduct = new Entities.Product(productData);
                    // TODO: we should really only add this in the case
                    //       the products is of type 'added'
                    products.add(newProduct);

                    // reload list
                    layout.trigger('display:added-to-page');
                    // also change the tab UI
                    layout.$('#added-to-page').click();
                });
                productList = new Views.PageProductList({collection: products, added: false});
                layout.on('display:needs-review', function () {
                    products = App.request('product:entities:paged', storeId, pageId);
                    productList = new Views.PageProductList({collection: products, added: false});
                    layout.productList.show(productList);
                });
                layout.on('display:added-to-page', function () {
                    products = App.request('added-to-page:product:entities:paged', storeId, pageId);
                    productList = new Views.PageProductList({collection: products, added: true});
                    layout.productList.show(productList);
                });
                layout.on('render', function () {
                    layout.productList.show(productList);
                });
                layout.on('save', function () {
                    $.when(page.save()).done(function (data) {
                        // TODO: Should we only do this when pageId === 'new'?
                        var store = data['store-id'],
                            page = data.id;

                        App.navigate('/' + store + '/pages/' + page + '/content',
                            {
                                trigger: true
                            });
                    });
                });
                this.region.show(layout);
            },
            pagesContent: function (storeId, pageId) {
                var contents, contentList, layout, page;
                page = App.routeModels.get('page');   // Why does this return an empty model?
                contents = App.request('needs-review:content:entities:paged', storeId, pageId);

                var fetchRelatedProducts = function(contents) {
                    App.execute('when:fetched', contents, function() {
                        // for each product, fetch their content image
                        contents.collect(function(content) {
                            var products = content.get('tagged-products');
                            if (products) {
                                products.collect(function(product) {
                                    App.request('fetch:product', storeId, product);
                                });
                            }
                        });
                    });
                };
                fetchRelatedProducts(contents);

                content_list = new Views.PageCreateContentList({ collection: contents });
                layout = new Views.PageCreateContent({
                    model: page
                });

                // Item View Actions
                layout.on('content_list:itemview:add_content', function (list_view, item_view) {
                    var content = item_view.model;
                    App.request('page:add_content', page, content);
                });
                layout.on('content_list:itemview:remove_content', function (list_view, item_view) {
                    var content = item_view.model;
                    App.request('page:remove_content', page, content);
                });
                layout.on('content_list:itemview:prioritize_content', function (list_view, item_view) {
                    var content = item_view.model;
                    App.request('page:prioritize_content', page, content);
                });

                // Displayed Content
                layout.on('display:all-content', function() {
                    // TODO: this introduces a race-condition on reset...
                    //       since a new AJAX request, should cancel the effect of the others
                    contents.reset();
                    var new_contents = App.request("content:entities:paged", store_id, page_id);
                    App.execute("when:fetched", new_contents, function() {
                        contents.reset(new_contents.models);
                    });
                });
                layout.on('display:suggested-content', function() {
                    // TODO: this introduces a race-condition on reset...
                    //       since a new AJAX request, should cancel the effect of the others
                    contents.reset();
                    var new_contents = App.request("needs-review:content:entities:paged", store_id, page_id);
                    App.execute("when:fetched", new_contents, function() {
                        contents.reset(new_contents.models);
                    });
                });
                layout.on('display:added-content', function() {
                    // TODO: this introduces a race-condition on reset...
                    //       since a new AJAX request, should cancel the effect of the others
                    contents.reset();
                    var new_contents = App.request("added-to-page:content:entities:paged", store_id, page_id);
                    App.execute("when:fetched", new_contents, function() {
                        contents.reset(new_contents.models);
                    });
                });
                layout.on('render', function () {
                    layout.contentList.show(contentList);
                });

                layout.on('save', function () {
                    $.when(page.save()).done(function (data) {
                        // TODO: Should we only do this when pageId === 'new'?
                        var store = data['store-id'],
                            page = data.id;

                        App.navigate('/' + store + '/pages/' + page + '/publish',
                            {
                                trigger: true
                            });
                    });
                });

                this.region.show(layout);
            },
            /**
             * Shows in iframe with the page in it.
             */
            pagesView: function (storeId, pageId, data) {
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

                App.execute('when:fetched', page, function () {
                    App.execute('when:fetched', store, function () {
                        $.ajax(data || getBucketInfo(page, store))
                            .done(function () {
                                var view = new Views.PagePreview({
                                    model: new Entities.Model(data)
                                });
                                self.region.show(view);
                            })
                            .fail(function () {
                                // S3 emits 404 if page not generated
                                self.publishView.apply(self, args);
                            });
                    });
                });
            },
            publishView: function (storeId, pageId) {
                var page, store, layout, self = this;
                page = App.routeModels.get('page');
                store = App.routeModels.get('store');

                layout = new Views.PublishPage({
                    model: page,
                    store: store
                });
                layout.on('publish', function () {
                    // TODO: move static_pages API under /graph/v1. ain't nobody got time for that today
                    var req, baseUrl = App.API_ROOT
                        .replace('/graph/v1', '/static_pages')
                        .replace(':9000', ':8000');

                    // TODO: less fugly handler
                    layout.$('.publish.button').text('Publishing...');
                    layout.$(layout.fail.el).hide();

                    // TODO: handle case where pageId is 'new'
                    req = $.ajax({
                        url: baseUrl + '/' + storeId + '/' + pageId + '/regenerate',
                        type: 'POST',
                        dataType: 'jsonp'
                    });
                    req.done(function (data) {
                        // crude as it is, this is also an option
                        // window.open('http://' + data.result.bucket_name + '/' +
                        //     data.result.s3_path);
                        self.pagesView(storeId, pageId, data);
                    });
                    req.fail(function () {
                        // TODO: less fugly handler
                        layout.$('.publish.button').text('Publish Page');
                        layout.$(layout.fail.el).show();
                    });
                });

                App.execute('when:fetched', page, function () {
                    App.execute('when:fetched', store, function () {

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

                        self.region.show(layout);
                    });
                });
            }
        });
        return PageWizard;
    });
