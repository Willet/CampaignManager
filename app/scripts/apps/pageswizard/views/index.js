define(["marionette", "../views", "backbone.stickit"],
    function (Marionette, Views) {
        "use strict";

        Views.PageIndex = Marionette.Layout.extend({
            template: "page/index",
            regions: {
                'list': ".list"
            },
            events: {
                'change select.sort-order': 'updateSortBy',
                'keyup input#js-page-search': 'filterPages'
            },
            triggers: {
                "click #new-page": "new-page",
                "click #edit-most-recent": "edit-most-recent"
            },
            updateSortBy: function (event) {
                var order;
                order = this.$(event.currentTarget).val();
                return this.trigger('change:sort-order', order);
            },
            filterPages: function (event) {
                return this.trigger('change:filter',
                    this.$(event.currentTarget).val());
            },
            serializeData: function () {
                return {
                    pages: this.collection.toJSON(),
                    'store-id': this.options['store-id']
                };
            },
            initialize: function (opts) {
                this.collection = this.model;
                this.store = opts.store;
                return this.collection;
            },
            onShow: function () {
                this.trigger('change:sort-order', 'last-modified');
                return this.list.show(new Views.PageIndexList({
                    model: this.collection,
                    store: this.store
                }));
            }
        });

        Views.PageIndexList = Marionette.ItemView.extend({
            template: "page/index_list",
            serializeData: function () {
                return {
                    pages: this.model.toJSON(),
                    store: this.store.toJSON()
                };
            },
            initialize: function (opts) {
                var _this = this;
                this.store = opts.store;

                this.model.on("reset", function () {
                    return _this.render();
                });
                return this.model.on("sort", function () {
                    return _this.render();
                });
            }
        });
        return Views;
    });
