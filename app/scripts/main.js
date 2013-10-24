/*global require*/
require.config({
    paths: {
        jquery: '../bower_components/jquery/jquery',
        backbone: '../bower_components/backbone/backbone',
        'backbone.projections': '../bower_components/backbone.projections/backbone.projections',
        'backbone.stickit': '../bower_components/backbone.stickit/backbone.stickit',
        'backbone.viewmodel': 'lib/backbone.viewmodel',
        handlebars: '../bower_components/handlebars.js/dist/handlebars',
        marionette: '../bower_components/marionette/lib/backbone.marionette',
        moment: '../bower_components/moment/moment',
        requirejs: '../bower_components/requirejs/require',
        'sass-bootstrap': '../bower_components/sass-bootstrap/dist/js/bootstrap',
        select2: '../bower_components/select2/select2',
        sinon: '../bower_components/sinonjs/sinon',
        swag: '../bower_components/swag/lib/swag',
        underscore: '../bower_components/underscore/underscore',
        foundation: '../bower_components/foundation/js/foundation',
        templates: 'templates',
        text: '../bower_components/requirejs-text/text'
    },
    shim: {
        'backbone': {
            // These script dependencies should be loaded before loading
            // backbone.js
            deps: ['jquery', 'underscore'],
            //Once loaded, use the global 'Backbone' as the
            //module value.
            exports: 'Backbone'
        },
        'backbone.projections': {
            deps: ['jquery', 'underscore', 'backbone']
        },
        'backbone.stickit': {
            deps: ['backbone'],
            exports: 'Backbone.Stickit'
        },
        'backbone.viewmodel': {
          deps: ['backbone'],
          exports: 'Backbone.ViewModel'
        },
        'jquery': {
            exports: '$'
        },
        'underscore': {
            exports: '_'
        },
        'marionette': {
            deps: ['backbone'],
            exports: 'Backbone.Marionette'
        },
        handlebars: {
            exports: 'Handlebars'
        },
        'templates': {
            deps: ['handlebars'],
            exports: 'JST'
        },
        select2: { // otherwise it might bind to the wrong jquery object
            deps: ['jquery']
        },
        sinon: {
            exports: 'sinon'
        },
        'swag': {
            deps: ['handlebars', 'underscore'],
            exports: 'Swag'
        },
        'foundation/foundation': ['jquery'],
        'foundation/foundation.abide': ['jquery', 'foundation/foundation'],
        'foundation/foundation.alerts': ['jquery', 'foundation/foundation'],
        'foundation/foundation.clearing': ['jquery', 'foundation/foundation'],
        'foundation/foundation.cookie': ['jquery', 'foundation/foundation'],
        'foundation/foundation.forms': ['jquery', 'foundation/foundation'],
        'foundation/foundation.interchange': ['jquery', 'foundation/foundation'],
        'foundation/foundation.joyride': ['jquery', 'foundation/foundation'],
        'foundation/foundation.magellan': ['jquery', 'foundation/foundation'],
        'foundation/foundation.orbit': ['jquery', 'foundation/foundation'],
        'foundation/foundation.placeholder': ['jquery', 'foundation/foundation'],
        'foundation/foundation.reveal': ['jquery', 'foundation/foundation'],
        'foundation/foundation.section': ['jquery', 'foundation/foundation'],
        'foundation/foundation.tooltips': ['jquery', 'foundation/foundation'],
        'foundation/foundation.topbar': ['jquery', 'foundation/foundation']
    }
});

require([
    "app",
    "jquery",
    "global/click_handler",
    "global/form_serialize",
    "config/backbone/model",
    "config/marionette/application",
    "config/marionette/renderer",
    "config/marionette/view",
    "config/marionette/router",
    "config/marionette/controller",
    "dao/base",
    "dao/pages",
    "dao/scrape",
    "dao/stores",
    "dao/content",
    "dao/products",
    "dao/tile-config",
    "dao/user",
    // sub apps to load, they attach to the root application
    "apps/main/app",
    "apps/contentmanager/app",
    "apps/pageswizard/app"
], function (App, $) {
    'use strict';
    $().ready(function () {
        App.start();
    });
});
