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
    Entities.Scrape = (function (_super) {

        __extends(Scrape, _super);

        function Scrape() {
            return Scrape.__super__.constructor.apply(this, arguments);
        }

        Scrape.prototype.STATUS = {
            1: "Started",
            2: "Requested",
            3: "Processing...",
            4: "Finished"
        };

        Scrape.prototype.defaults = {
            status: 1
        };

        Scrape.prototype.viewJSON = function (opts) {
            var json;
            json = this.toJSON(opts);
            json['status'] = this.STATUS[json['status']];
            return json;
        };

        return Scrape;

    })(Base.Model);
    Entities.ScrapeCollection = (function (_super) {

        __extends(ScrapeCollection, _super);

        function ScrapeCollection() {
            return ScrapeCollection.__super__.constructor.apply(this,
                arguments);
        }

        ScrapeCollection.prototype.model = Entities.Scrape;

        return ScrapeCollection;

    })(Base.Collection);
    return Entities;
});
