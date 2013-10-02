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

define(["entities/base"], function (Base) {
    var Entities;
    Entities = Entities || {};
    Entities.Product = (function (_super) {

        __extends(Product, _super);

        function Product() {
            return Product.__super__.constructor.apply(this, arguments);
        }

        Product.prototype.viewJSON = function () {
            var json, _ref, _ref1;
            json = this.toJSON();
            json['content-ids'] = (_ref = this.get('content-ids')) != null
                ? _ref.viewJSON() : void 0;
            json['default-image-id'] = (_ref1 = this.get('default-image-id')) != null
                ? _ref1.viewJSON() : void 0;
            return json;
        };

        return Product;

    })(Base.Model);
    Entities.ProductCollection = (function (_super) {

        __extends(ProductCollection, _super);

        function ProductCollection() {
            return ProductCollection.__super__.constructor.apply(this,
                arguments);
        }

        ProductCollection.prototype.model = Entities.Product;

        ProductCollection.prototype.initialize = function (models, opts) {
            if (opts) {
                return this.hasmodel = opts['model'];
            }
        };

        ProductCollection.prototype.url = function (opts) {
            var _ref,
                _this = this;
            this.store_id = ((_ref = this.hasmodel) != null
                ? typeof _ref.get === "function" ? _ref.get('store-id')
                                 : void 0 : void 0) || this.store_id;
            _.each(opts, function (m) {
                return m.set("store-id", _this.store_id);
            });
            return "" + (require("app").apiRoot) + "/stores/" + this.store_id + "/products";
        };

        ProductCollection.prototype.parse = function (data) {
            return data['products'];
        };

        ProductCollection.prototype.viewJSON = function () {
            return this.collect(function (m) {
                return m.viewJSON();
            });
        };

        return ProductCollection;

    })(Base.Collection);
    return Entities;
});
