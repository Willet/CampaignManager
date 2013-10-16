define(["marionette", "../views"], function (Marionette, Views) {
    var _ref;
    Views.GeneratePage = Marionette.Layout.extend({
        template: "page/generate",
        triggers: {
            "click .js-next": "generate"
        },
        onRender: function (opts) {
            return this.$(".steps .generate").addClass("active")
        }
    });

    return Views;
});
