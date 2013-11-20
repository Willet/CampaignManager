define(['app', '../views', './header'], function (App, Views) {
    'use strict';
    Views.PageManagerLayout = App.Views.Layout.extend({
        template: 'page/shared/wizard_layout',
        id: 'page_wizard',
        regions: {
            'content': '.content-region',
            'header': '.header-region'
        },
        onShow: function () {
        }
    });
    return Views;
});
