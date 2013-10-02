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

define(["marionette"], function (Marionette) {
    var Index, Loading, Main, Nav, NotFound, TitleBar;
    Loading = (function (_super) {

        __extends(Loading, _super);

        function Loading() {
            return Loading.__super__.constructor.apply(this, arguments);
        }

        Loading.prototype.template = "loading";

        Loading.prototype.initialize = function (opts) {
            var defaults;
            defaults = {
                initialized: true,
                emptyMessage: "There are no items matching your criteria",
                loadingMessage: "Please wait. Loading..."
            };
            return this.options = _.extend(defaults, opts);
        };

        Loading.prototype.serializeData = function () {
            return {
                message: (this.options['initialized']
                    ? this.options['loadingMessage']
                    : this.options['emptyMessage'])
            };
        };

        return Loading;

    })(Marionette.ItemView);
    Main = (function (_super) {

        __extends(Main, _super);

        function Main() {
            return Main.__super__.constructor.apply(this, arguments);
        }

        Main.prototype.template = "main_index";

        return Main;

    })(Marionette.ItemView);
    Nav = (function (_super) {

        __extends(Nav, _super);

        function Nav() {
            return Nav.__super__.constructor.apply(this, arguments);
        }

        Nav.prototype.template = "nav";

        Nav.prototype.initialize = function (opts) {
            var _this = this;
            return this.model.on("change", function () {
                return _this.render();
            });
        };

        Nav.prototype.serializeData = function () {
            var json;
            json = {};
            if (this.model.get('store')) {
                json['store'] = this.model.get('store').toJSON();
            }
            json['page'] = this.model.get('page');
            return json;
        };

        return Nav;

    })(Marionette.ItemView);
    TitleBar = (function (_super) {

        __extends(TitleBar, _super);

        function TitleBar() {
            return TitleBar.__super__.constructor.apply(this, arguments);
        }

        TitleBar.prototype.template = "title_bar";

        TitleBar.prototype.initialize = function (opts) {
            var _this = this;
            return this.model.on("change", function () {
                return _this.render();
            });
        };

        return TitleBar;

    })(Marionette.ItemView);
    NotFound = (function (_super) {

        __extends(NotFound, _super);

        function NotFound() {
            return NotFound.__super__.constructor.apply(this, arguments);
        }

        NotFound.prototype.template = "404";

        return NotFound;

    })(Marionette.ItemView);
    Index = (function (_super) {

        __extends(Index, _super);

        function Index() {
            return Index.__super__.constructor.apply(this, arguments);
        }

        Index.prototype.template = "stores_index";

        return Index;

    })(Marionette.Layout);
    return {
        Main: Main,
        Nav: Nav,
        TitleBar: TitleBar,
        Loading: Loading,
        NotFound: NotFound,
        Index: Index
    };
});
