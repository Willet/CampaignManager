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

define(['backbone', 'jquery', 'underscore', 'backboneuniquemodel'],
    function (Backbone, $, _) {
        var Base, reverseSortFn;
        Base = Base || {};
        Base.Model = (function (_super) {

            __extends(Model, _super);

            function Model() {
                return Model.__super__.constructor.apply(this, arguments);
            }

            Model.prototype.blacklist = ['selected'];

            Model.prototype.viewJSON = function (opts) {
                return _.clone(this.attributes);
            };

            Model.prototype.toJSON = function (opts) {
                return _.omit(this.attributes, this.blacklist || {});
            };

            Model.prototype.fetch = function () {
                return this._fetch = Model.__super__.fetch.apply(this,
                    arguments);
            };

            Model.prototype.sync = function () {
                return this._fetch = Model.__super__.sync.apply(this,
                    arguments);
            };

            return Model;

        })(Backbone.Model);
        reverseSortFn = function (sortFn) {
            return function (left, right) {
                var l, r;
                l = sortFn(left);
                r = sortFn(right);
                if (l < r) {
                    return 1;
                } else if (l > r) {
                    return -1;
                } else {
                    return 0;
                }
            };
        };
        Base.Collection = (function (_super) {

            __extends(Collection, _super);

            function Collection() {
                return Collection.__super__.constructor.apply(this, arguments);
            }

            Collection.prototype.comparator = function (model) {
                return model.get("id");
            };

            Collection.prototype.viewJSON = function () {
                return this.collect(function (m) {
                    return m.viewJSON();
                });
            };

            Collection.prototype.updateSortBy = function (field, reverse) {
                if (reverse == null) {
                    reverse = false;
                }
                this.comparator = function (m) {
                    return m.get(field);
                };
                if (reverse) {
                    this.comparator = reverseSortFn(this.comparator);
                }
                return this.sort();
            };

            Collection.prototype.fetch = function () {
                return this._fetch = Collection.__super__.fetch.apply(this,
                    arguments);
            };

            return Collection;

        })(Backbone.Collection);
        return Base;
    });
