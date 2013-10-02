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
    Views.PageCreateContent = (function (_super) {

        __extends(PageCreateContent, _super);

        function PageCreateContent() {
            return PageCreateContent.__super__.constructor.apply(this,
                arguments);
        }

        PageCreateContent.prototype.template = "pages_content";

        PageCreateContent.prototype.serializeData = function () {
            return {
                page: this.model.toJSON(),
                "store-id": this.model.get("store-id"),
                "title": this.model.get("name")
            };
        };

        PageCreateContent.prototype.triggers = {
            "click .js-next": "save"
        };

        PageCreateContent.prototype.regions = {
            "contentList": ".content > .list"
        };

        PageCreateContent.prototype.initialize = function (opts) {
        };

        PageCreateContent.prototype.onRender = function (opts) {
            return this.$(".steps .content").addClass("active");
        };

        PageCreateContent.prototype.onShow = function (opts) {
        };

        return PageCreateContent;

    })(Marionette.Layout);
    return Views;
});
