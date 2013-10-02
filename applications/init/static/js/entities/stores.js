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

define(["app", "entities/base"], function (App, Base) {
    var Entities;
    Entities = Entities || {};
    Entities.Store = (function (_super) {

        __extends(Store, _super);

        function Store() {
            return Store.__super__.constructor.apply(this, arguments);
        }

        return Store;

    })(Base.Model);
    Entities.StoreCollection = (function (_super) {

        __extends(StoreCollection, _super);

        function StoreCollection() {
            return StoreCollection.__super__.constructor.apply(this,
                arguments);
        }

        StoreCollection.prototype.model = Entities.Store;

        StoreCollection.prototype.parse = function (data) {
            return data['stores'];
        };

        return StoreCollection;

    })(Base.Collection);
    return Entities;
});
