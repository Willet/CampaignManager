require([
    'app',
    'jquery',
    'global/ajax_setup',
    'global/click_handler',
    'global/form_serialize',
    'controllers/base_controller',
    'config/ie',
    'config/base/views/collectionview',
    'config/base/views/compositeview',
    'config/base/views/itemview',
    'config/base/views/layout',
    'config/backbone/model',
    'config/backbone/view',
    'config/marionette/application',
    'config/marionette/renderer',
    'config/marionette/view',
    'config/marionette/router',
    'config/marionette/controller',
    'dao/base',
    'dao/pages',
    'dao/scrape',
    'dao/stores',
    'dao/content',
    'dao/products',
    'dao/tile-config',
    'dao/user',
    // sub apps to load, they attach to the root application
    'apps/main/app',
    'apps/contentmanager/app',
    'apps/pagemanager/app'
], function (App, $) {
    'use strict';
    if (window.ENVIRONMENT !== 'test') {
        $().ready(function () {
            App.start();
        });
    }
});
