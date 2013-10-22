define(["marionette", "../views", "backbone", "backbone.stickit"],
    function (Marionette, Views, Backbone, Stickit) {
        "use strict";
        var _ref;
        Views.PublishPage = Marionette.Layout.extend({
            'regions': {
                'publishFail': '.fail'
            },
            template: "page/publish",
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
                "click .js-next": "publish"
            },
            onRender: function (opts) {
                this.stickit();
                this.$('.fail').hide();

                return this.$(".steps .publish").addClass("active");
            }
        });

        return Views;
    });
