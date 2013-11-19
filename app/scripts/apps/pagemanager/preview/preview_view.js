define(['app', '../views', 'backbone.stickit'],
    function (App, Views) {
        'use strict';
        Views.PagePreview = App.Views.Layout.extend({
            'template': 'page/view',
            'triggers': {
                'click .publish': 'publish'
            }
        });

        return Views;
    });
