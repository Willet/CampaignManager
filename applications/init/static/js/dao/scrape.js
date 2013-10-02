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

define(["app", "dao/base", "entities"], function (App, Base, Entities) {
    var API, DAO, ScrapeDAO;
    ScrapeDAO = (function (_super) {

        __extends(ScrapeDAO, _super);

        function ScrapeDAO() {
            return ScrapeDAO.__super__.constructor.apply(this, arguments);
        }

        return ScrapeDAO;

    })(Base);
    /*
     API =
     getScrape: (store_id, params = {}) ->
     scrapes = new Entities.ScrapeCollection
     scrapes.url = "#{App.apiRoot}/stores/#{store_id}/scraper"
     scrapes.fetch
     reset: true
     data: params
     scrapes
     */

    DAO = (function () {

        DAO.prototype.actions = [];

        function DAO(options) {
        }

        DAO.prototype._initializeActions = function () {
            var _this = this;
            return _.each(this.actions, function (action) {
                return _this[action] = _.partial(_this._action, action);
            });
        };

        DAO.prototype._action = function (action, params) {
            if (params == null) {
                params = {};
            }
            return $.getJSON(this.url() + "/" + action, params);
        };

        DAO.prototype.whenFetched = function (promise, fn) {
            return $.when(promise).done(fn);
        };

        return DAO;

    })();
    ScrapeDAO = (function (_super) {

        __extends(ScrapeDAO, _super);

        function ScrapeDAO() {
            return ScrapeDAO.__super__.constructor.apply(this, arguments);
        }

        ScrapeDAO.prototype.actions = ["update"];

        return ScrapeDAO;

    })(DAO);
    API = {
        getScrapes: function (store_id, params) {
            var data;
            if (params == null) {
                params = {};
            }
            data = [
                {
                    url: "http://www.ae.com/web/browse/product.jsp?productId=0154_8700",
                    status: 3,
                    title: "AE SHORT SLEEVE PLAID BUTTON DOWN",
                    page_id: params.page_id
                },
                {
                    url: "http://www.ae.com/web/browse/product.jsp?productId=8151_8593_567",
                    status: 4,
                    title: "AE CAMOUFLAGE WESTERN SHIRT",
                    page_id: params.page_id
                }
            ];
            return new Entities.ScrapeCollection(data);
        }
    };
    App.reqres.setHandler("page:scrapes:entities",
        function (store_id, page_id) {
            return API.getScrapes(store_id, {
                page_id: page_id
            });
        });
    return DAO.scrape = new ScrapeDAO();
});
