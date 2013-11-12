define(['marionette', '../views', './header'], function (Marionette, Views) {
    'use strict';
    Views.PageWizardLayout = Marionette.Layout.extend({
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
