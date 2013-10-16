define(["marionette", "../views", "backbone.stickit"], function (Marionette, Views) {
    var _ref;
    Views.GeneratePage = Marionette.Layout.extend({
        template: "page/generate",
        triggers: {
            "click .js-next": "generate"
        },
        onRender: function (opts) {
            // is this necessary?
            this.stickit();
            return this.$(".steps .generate").addClass("active")
        }
    });

    return Views;
});
