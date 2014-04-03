/*global require*/
'use strict';

require.config({
    deps: ['main'], // the script that will be loaded at start
    paths: {
        jquery: '../bower_components/jquery/jquery',
        backbone: '../bower_components/backbone/backbone',
        'backbone.projections': '../bower_components/backbone.projections/backbone.projections',
        'backbone.stickit': '../bower_components/backbone.stickit/backbone.stickit',
        'backbone.viewmodel': 'lib/backbone.viewmodel',
        'backbone.uniquemodel': '../bower_components/backbone.uniquemodel/backbone.uniquemodel',
        'backbone-associations': '../bower_components/backbone-associations/backbone-associations',
        'backbone.computedfields': '../bower_components/backbone.computedfields/lib/backbone.computedfields',
        handlebars: 'lib/handlebars-v1.1.1',
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
        text: '../bower_components/requirejs-text/text',
        cloudinary: '../bower_components/cloudinary/js/jquery.cloudinary'
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
        'backbone.uniquemodel': {
            deps: ['backbone'],
            exports: 'Backbone.UniqueModel'
        },
        'backbone-associations': {
            deps: ['backbone'],
            exports: 'Backbone.Associations'
        },
        'backbone.computedfields': {
            deps: ['backbone']
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
        'cloudinary': {
            deps: ['jquery']
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
