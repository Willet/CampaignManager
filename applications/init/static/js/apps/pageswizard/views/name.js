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
    Views.PageCreateName = (function (_super) {

        __extends(PageCreateName, _super);

        function PageCreateName() {
            return PageCreateName.__super__.constructor.apply(this, arguments);
        }

        PageCreateName.prototype.template = "pages_name";

        PageCreateName.prototype.serializeData = function () {
            return {
                page: this.model.toJSON(),
                "store-id": this.model.get("store-id"),
                "title": this.model.get("name")
            };
        };

        PageCreateName.prototype.triggers = {
            "click .js-next": "save"
        };

        PageCreateName.prototype.bindings = {
            'input[for=name]': {
                observe: 'name',
                events: ['blur']
            },
            'input[for=url]': {
                observe: 'url',
                events: ['blur']
            }
        };

        PageCreateName.prototype.initialize = function (opts) {
        };

        PageCreateName.prototype.onRender = function (opts) {
            this.stickit();
            return this.$(".steps .main").addClass("active");
        };

        PageCreateName.prototype.onShow = function (opts) {
        };

        return PageCreateName;

    })(Marionette.Layout);
    return Views;
});
