requirejs.config(
  # Remember: only use shim config for non-AMD scripts,
  # scripts that do not already call define(). The shim
  # config will not work correctly if used on AMD scripts,
  # in particular, the exports and init config will not
  # be triggered, and the deps config will be confusing
  # for those cases.

  paths:
    backbone: 'libs/backbone/backbone-min'
    underscore: 'libs/underscore/underscore-min'
    jquery: 'libs/jquery/jquery.min'
    jquery_ui: '//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min'
    marionette: 'libs/marionette/lib/backbone.marionette.min'
    backboneprojections: 'backbone.projections'
    handlebars: 'libs/handlebars.js/dist/handlebars.runtime'
    swag: 'libs/swag/lib/swag.min'
    templates: '../templates/templates.pre.min'
    foundation: 'foundation'
    select2: 'libs/select2/select2.min'
    stickit: 'libs/backbone.stickit/backbone.stickit'
    modernizr: 'libs/modernizr/modernizr'
  shim:
    jquery:
      exports: 'jQuery'
    jquery_ui:
      deps: ['jquery']
    select2:
      deps: ['jquery']
    backbone:
      deps: ['underscore', 'jquery']
      exports: 'Backbone'
    marionette:
      deps: ['jquery', 'underscore', 'backbone']
      exports: 'Marionette'
    backboneprojections:
      deps: ['backbone']
      exports: 'BackboneProjections'
    stickit:
      depts: ['jquery', 'backbone']
    underscore:
      exports: '_'
    handlebars:
      exports: 'Handlebars'
    swag:
      deps: ['handlebars']
      exports: 'Swag'
    templates:
      deps: ['handlebars']
      exports: 'JST'
    foundation: ['jquery']
    'foundation/abide': ['jquery', 'foundation']
    'foundation/alerts': ['jquery', 'foundation']
    'foundation/clearing': ['jquery', 'foundation']
    'foundation/cookie': ['jquery', 'foundation']
    'foundation/forms': ['jquery', 'foundation']
    'foundation/interchange': ['jquery', 'foundation']
    'foundation/joyride': ['jquery', 'foundation']
    'foundation/magellan': ['jquery', 'foundation']
    'foundation/orbit': ['jquery', 'foundation']
    'foundation/placeholder': ['jquery', 'foundation']
    'foundation/reveal': ['jquery', 'foundation']
    'foundation/section': ['jquery', 'foundation']
    'foundation/tooltips': ['jquery', 'foundation']
    'foundation/topbar': ['jquery', 'foundation']
)

# Global Init of Modules Required (loaded in order)
require [
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
  # sub apps to load, they attach to the root application
  "apps/main/app",
  "apps/contentmanager/app",
  "apps/pageswizard/app"
], (App, $) ->
  $().ready(-> App.start())
