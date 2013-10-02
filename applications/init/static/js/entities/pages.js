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
    Entities.Page = (function (_super) {

        __extends(Page, _super);

        function Page() {
            return Page.__super__.constructor.apply(this, arguments);
        }

        Page.prototype.toJSON = function () {
            var json;
            json = _.clone(this.attributes);
            if (json['fields']) {
                json['fields'] = JSON.stringify(json['fields']);
            }
            return json;
        };

        Page.prototype.parse = function (data) {
            var json;
            json = data;
            if (json && json['fields']) {
                json['fields'] = $.parseJSON(json['fields']);
            }
            return json;
        };

        return Page;

    })(Base.Model);
    Entities.PageCollection = (function (_super) {

        __extends(PageCollection, _super);

        function PageCollection() {
            return PageCollection.__super__.constructor.apply(this, arguments);
        }

        PageCollection.prototype.model = Entities.Page;

        PageCollection.prototype.parse = function (data) {
            return data['campaigns'];
        };

        return PageCollection;

    })(Base.Collection);
    return Entities;
});
