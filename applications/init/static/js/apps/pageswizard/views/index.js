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

define(["marionette", "../views", "stickit"], function (Marionette, Views) {
    Views.PageIndex = (function (_super) {

        __extends(PageIndex, _super);

        function PageIndex() {
            return PageIndex.__super__.constructor.apply(this, arguments);
        }

        PageIndex.prototype.template = "pages_index";

        PageIndex.prototype.regions = {
            'list': ".list"
        };

        PageIndex.prototype.events = {
            'change select.sort-order': 'updateSortBy',
            'keyup input#js-page-search': 'filterPages'
        };

        PageIndex.prototype.triggers = {
            "click #new-page": "new-page",
            "click #edit-most-recent": "edit-most-recent"
        };

        PageIndex.prototype.updateSortBy = function (event) {
            var order;
            order = this.$(event.currentTarget).val();
            return this.trigger('change:sort-order', order);
        };

        PageIndex.prototype.filterPages = function (event) {
            return this.trigger('change:filter',
                this.$(event.currentTarget).val());
        };

        PageIndex.prototype.serializeData = function () {
            return {
                pages: this.collection.toJSON(),
                'store-id': this.options['store-id']
            };
        };

        PageIndex.prototype.initialize = function (opts) {
            return this.collection = this.model;
        };

        PageIndex.prototype.onShow = function () {
            this.trigger('change:sort-order', 'last-modified');
            return this.list.show(new Views.PageIndexList({
                model: this.collection
            }));
        };

        return PageIndex;

    })(Marionette.Layout);
    Views.PageIndexList = (function (_super) {

        __extends(PageIndexList, _super);

        function PageIndexList() {
            return PageIndexList.__super__.constructor.apply(this, arguments);
        }

        PageIndexList.prototype.template = "pages_index_list";

        PageIndexList.prototype.serializeData = function () {
            return {
                pages: this.model.toJSON()
            };
        };

        PageIndexList.prototype.initialize = function () {
            var _this = this;
            this.model.on("reset", function () {
                return _this.render();
            });
            return this.model.on("sort", function () {
                return _this.render();
            });
        };

        return PageIndexList;

    })(Marionette.ItemView);
    return Views;
});
