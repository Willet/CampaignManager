define(["marionette", "../views"], function (Marionette, Views) {
    var _ref;
    Views.GeneratePage = Marionette.Layout.extend({
        template: "page/generate",
        triggers: {
            "click .generate": "generate"
        },
        onRender: function (opts) {
            $(".steps .layout").addClass("active")
        }
    });

    return Views;
});
