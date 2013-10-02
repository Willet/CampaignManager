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
    Views.PageCreateProducts = (function (_super) {

        __extends(PageCreateProducts, _super);

        function PageCreateProducts() {
            return PageCreateProducts.__super__.constructor.apply(this,
                arguments);
        }

        PageCreateProducts.prototype.template = "pages_products";

        PageCreateProducts.prototype.events = {
            "click #add-url": "addUrl",
            "click #add-product": "addProduct",
            "keydown #url": "resetError"
        };

        PageCreateProducts.prototype.triggers = {
            "click .js-next": "save"
        };

        PageCreateProducts.prototype.resetError = function (event) {
            return $(event.currentTarget).removeClass("error");
        };

        PageCreateProducts.prototype.validUrl = function (url) {
            var urlPattern;
            urlPattern = /(http|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/;
            return url && url !== "" && urlPattern.test(url);
        };

        PageCreateProducts.prototype.addUrl = function (event) {
            if (this.validUrl(this.$('#url').val())) {
                this.trigger("new:scrape", this.$('#url').val());
                return this.$('#url').val("");
            } else {
                return this.$('#url').addClass("error");
            }
        };

        PageCreateProducts.prototype.serializeData = function () {
            return {
                page: this.model.toJSON(),
                "store-id": this.model.get("store-id"),
                "title": this.model.get("name")
            };
        };

        PageCreateProducts.prototype.regions = {
            "scrapeList": "#scrape-list",
            "productList": "#product-list"
        };

        PageCreateProducts.prototype.initialize = function (opts) {
        };

        PageCreateProducts.prototype.onRender = function (opts) {
            return this.$(".steps .products").addClass("active");
        };

        PageCreateProducts.prototype.onShow = function (opts) {
        };

        return PageCreateProducts;

    })(Marionette.Layout);
    Views.PageScrapeItem = (function (_super) {

        __extends(PageScrapeItem, _super);

        function PageScrapeItem() {
            return PageScrapeItem.__super__.constructor.apply(this, arguments);
        }

        PageScrapeItem.prototype.template = "_page_scrape_item";

        PageScrapeItem.prototype.triggers = {
            "click .remove": "remove"
        };

        PageScrapeItem.prototype.serializeData = function () {
            return this.model.viewJSON();
        };

        return PageScrapeItem;

    })(Marionette.ItemView);
    Views.PageScrapeList = (function (_super) {

        __extends(PageScrapeList, _super);

        function PageScrapeList() {
            return PageScrapeList.__super__.constructor.apply(this, arguments);
        }

        PageScrapeList.prototype.itemView = Views.PageScrapeItem;

        return PageScrapeList;

    })(Marionette.CollectionView);
    return Views;
});
