define(['app', './app', 'backbone.projections', 'marionette', 'jquery', 'underscore', './views', 'entities'],
    function (App, PageWizard, BackboneProjections, Marionette, $, _, Views, Entities) {
        'use strict';

        PageWizard.Controller = Marionette.Controller.extend({

            pagesIndex: function (storeId) {
                var allModels, pages, store, view;

                // gets a list of pages belonging to this store.
                pages = App.request('page:all', storeId);
                store = App.request('store:get', {'store_id': storeId});
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

            pagesProducts: function (storeId) {
                var layout, store, page, products, productList, _this = this;
                store = App.routeModels.get('store');
                page = App.routeModels.get('page');
                App.execute('when:fetched', [store, page], function() {
                    products = App.request('page:products', page);

                    App.execute('when:fetched', products, function() {
                        // for each product, fetch their content image
                        products.collect(function(product) {
                            App.request('fetch:content', storeId, product.get('default-image-id'));
                        });
                    });

                    layout = new Views.PageCreateProducts({
                        model: page
                    });
                    layout.on('select-all', function() {
                        products.collect(function(model) { model.set('selected', true); });
                        productList.render();
                    });
                    layout.on('added-product', function (productData) {
                        var newProduct = new Entities.Product(productData);
                        // reload list
                        layout.trigger('display:added-to-page');
                        // also change the tab UI
                        layout.$('#added-to-page').click();
                        // TODO: we should really only add this in the case
                        //       the products is of type 'added'
                        products.add(newProduct);
                    });
                    layout.on('product_list:itemview:remove', function (listView, itemView) {
                        var product = itemView.model;
                        App.request('page:add_product', page, product);
                    });
                    layout.on('product_list:itemview:remove', function (listView, itemView) {
                        var product = itemView.model;
                        App.request('page:remove_product', page, product);
                    });
                    layout.on('product_list:itemview:preview_product', function (listView, itemView) {
                        var product = itemView.model;
                        App.modal.show(new Views.PageCreateProductPreview({model: product}));
                    });
                    productList = new Views.PageProductList({collection: products, added: false, itemView: Views.PageProductGridItem });
                    layout.on('grid-view', function () {
                        productList.itemView = Views.PageProductGridItem;
                        productList.render();
                    });
                    layout.on('list-view', function () {
                        productList.itemView = Views.PageProductListItem;
                        productList.render();
                    });
                    // Displayed Product
                    layout.on('change:filter', function () {
                        var filter = layout.extractFilter();
                        products.setFilter(filter);
                    });
                    layout.on('display:all-product', function() {
                        // TODO: this introduces a race-condition on reset...
                        //       since a new AJAX request, should cancel the effect of the others
                        products.reset();
                        var newProducts = App.request('store:products', store, {filter: layout.extractFilter() });
                        productList.showLoading();
                        App.execute('when:fetched', newProducts, function() {
                            products.reset(newProducts.models);
                            productList.hideLoading();
                        });
                    });
                    layout.on('display:import-product', function() {
                        // TODO: this introduces a race-condition on reset...
                        //       since a new AJAX request, should cancel the effect of the others
                        products.reset();
                        var newProducts = App.request('page:products', page, {filter: layout.extractFilter() });
                        App.execute('when:fetched', newProducts, function() {
                            products.reset(newProducts.models);
                        });
                    });
                    layout.on('display:added-product', function() {
                        // TODO: this introduces a race-condition on reset...
                        //       since a new AJAX request, should cancel the effect of the others
                        products.reset();
                        var newProducts = App.request('page:products', page, {filter: layout.extractFilter() });
                        App.execute('when:fetched', newProducts, function() {
                            products.reset(newProducts.models);
                        });
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
                    layout.on('render', function () {
                        layout.productList.show(productList);
                    });
                    _this.region.show(layout);
                });
            },

            pagesContent: function () {
                var contents, contentList, layout, store, page, _this = this;
                page = App.routeModels.get('page');   // Why does this return an empty model?
                store = App.routeModels.get('store');
                App.execute('when:fetched', [store, page], function() {
                    contents = App.request('content:all', store);

                    contentList = new Views.PageCreateContentList({ collection: contents, itemView: Views.PageCreateContentGridItem });
                    layout = new Views.PageCreateContent({
                        model: page
                    });

                    layout.on('grid-view', function() {
                        contentList = new Views.PageCreateContentList({ collection: contents, itemView: Views.PageCreateContentGridItem });
                        layout.contentList.show(contentList);
                    });

                    layout.on('list-view', function() {
                        contentList = new Views.PageCreateContentList({ collection: contents, itemView: Views.PageCreateContentListItem });
                        layout.contentList.show(contentList);
                    });

                    // Item View Actions
                    layout.on('content_list:itemview:add_content', function (listView, itemView) {
                        var content = itemView.model;
                        App.request('page:add_content', page, content);
                    });
                    layout.on('content_list:itemview:remove_content', function (listView, itemView) {
                        var content = itemView.model;
                        App.request('page:remove_content', page, content);
                    });
                    layout.on('content_list:itemview:prioritize_content', function (listView, itemView) {
                        var content = itemView.model;
                        App.request('page:prioritize_content', page, content);
                    });
                    layout.on('content_list:itemview:preview_content', function (listView, itemView) {
                        var content = itemView.model;
                        App.modal.show(new Views.PageCreateContentPreview({model: content}));
                    });

                    // Displayed Content
                    layout.on('change:filter', function () {
                        var filter = layout.extractFilter();
                        contents.setFilter(filter);
                    });
                    layout.on('select-all', function() {
                        contents.collect(function(model) { model.set('selected', true); });
                        contentList.render();
                    });
                    layout.on('select-none', function() {
                        contents.collect(function(model) { model.set('selected', false); });
                        contentList.render();
                    });
                    layout.on('add-selected', function() {
                        var selected = contents.filter(function(model) { return model.get('selected'); });
                        _.each(selected, function(model) {
                            App.request('page:add_content', page, model);
                            model.set('selected', false);
                        });
                        contentList.render();
                    });
                    layout.on('remove-selected', function() {
                        var selected = contents.filter(function(model) { return model.get('selected'); });
                        _.each(selected, function(model) {
                            App.request('page:remove_content', page, model);
                            model.set('selected', false);
                        });
                        contentList.render();
                    });
                    layout.on('display:all-content', function() {
                        // TODO: this introduces a race-condition on reset...
                        //       since a new AJAX request, should cancel the effect of the others
                        contents.reset();
                        var newContents = App.request('store:content', store, layout.extractFilter());
                        App.execute('when:fetched', newContents, function() {
                            contents.reset(newContents.models);
                        });
                    });
                    layout.on('display:suggested-content', function() {
                        // TODO: this introduces a race-condition on reset...
                        //       since a new AJAX request, should cancel the effect of the others
                        contents.reset();
                        var newContents = App.request('page:content', page, layout.extractFilter());
                        App.execute('when:fetched', newContents, function() {
                            contents.reset(newContents.models);
                        });
                    });
                    layout.on('display:added-content', function() {
                        // TODO: this introduces a race-condition on reset...
                        //       since a new AJAX request, should cancel the effect of the others
                        contents.reset();
                        var newContents = App.request('page:content', page, layout.extractFilter());
                        App.execute('when:fetched', newContents, function() {
                            contents.reset(newContents.models);
                        });
                    });
                    layout.on('render', function () {
                        layout.contentList.show(contentList);
                    });
                    layout.on('fetch:next-page', function() {
                        contents.getNextPage();
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

                    _this.region.show(layout);
                });
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
                    // TODO: HACK!!!
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
