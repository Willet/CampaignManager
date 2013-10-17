define(["marionette", "../views", "backbone.stickit"],
    function (Marionette, Views) {
        "use strict";
        Views.PagePreview = Marionette.Layout.extend({
            'template': "page/view"
        });

        return Views;
    });
