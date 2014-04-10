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
        cloudinary: '../bower_components/cloudinary/js/jquery.cloudinary',
        'load-image': '../bower_components/blueimp-load-image/js/load-image',
        'load-image-meta': '../bower_components/blueimp-load-image/js/load-image-meta',
        'load-image-exif': '../bower_components/blueimp-load-image/js/load-image-exif',
        'load-image-ios': '../bower_components/blueimp-load-image/js/load-image-ios',
        'canvas-to-blob': '../bower_components/blueimp-canvas-to-blob/js/canvas-to-blob',
        'jquery.fileupload-process': '../bower_components/blueimp-file-upload/js/jquery.fileupload-process',
        'jquery.ui.widget': '../bower_components/blueimp-file-upload/js/vendor/jquery.ui.widget',
        'jquery.fileupload-images': '../bower_components/blueimp-file-upload/js/jquery.fileupload-image',
        'jquery.fileupload': '../bower_components/blueimp-file-upload/js/jquery.fileupload'
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
        'load-image': {
            deps: ['jquery']
        },
        'load-image-meta': {
            deps: ['jquery']
        },
        'load-image-exif': {
            deps: ['jquery']
        },
        'load-image-ios': {
            deps: ['jquery']
        },
        'canvas-to-blob': {
            deps: ['jquery']
        },
        'jquery.ui.widget': {
            deps: ['jquery'],
            exports: 'jquery.ui.widget'
        },
        'jquery.fileupload': {
            deps: ['jquery', 'jquery.ui.widget'],
            exports: 'jquery.fileupload'
        },
        'jquery.fileupload-process': {
            deps: ['jquery', 'jquery.fileupload']
        },
        'jquery.fileupload-images': {
            deps: ['jquery', 'jquery.fileupload', 'load-image', 'load-image-meta',
                   'load-image-exif', 'load-image-ios', 'canvas-to-blob', 'jquery.fileupload-process']
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
