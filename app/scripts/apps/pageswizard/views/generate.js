define(["marionette", "../views", "backbone", "backbone.stickit"],
    function (Marionette, Views, Backbone, Stickit) {
        "use strict";
        var _ref;
        Views.GeneratePage = Marionette.Layout.extend({
            template: "page/generate",
            initialize: function (opts) {
                this.store = opts.store;
            },
            serializeData: function () {
                return {
                    page: this.model.toJSON(),
                    url: this.store.get("public-base-url"),
                    store: this.store.toJSON()
                };
            },
            triggers: {
                "click .js-next": "generate"
            },
            onRender: function (opts) {
                this.stickit();

                return this.$(".steps .generate").addClass("active");
            }
        });

        return Views;
    });
