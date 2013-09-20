requirejs.config(
  # Remember: only use shim config for non-AMD scripts,
  # scripts that do not already call define(). The shim
  # config will not work correctly if used on AMD scripts,
  # in particular, the exports and init config will not
  # be triggered, and the deps config will be confusing
  # for those cases.

  paths:
    backbone: 'backbone-min'
    underscore: 'lib/underscore'
    jquery: '//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min'
    jquery_ui: '//ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min'
    marionette: 'lib/backbone.marionette'
    backboneprojections: 'backbone.projections'
    backboneassociations: 'backbone-associations-min'
    handlebars: 'handlebars'
    templates: '../templates/templates.pre.min'
    jwerty: 'lib/jwerty'
    foundation: 'lib/foundation'
    backbonefetchcache: 'lib/backbone.fetch-cache'
    select2: 'lib/select2'
    stickit: 'lib/backbone.stickit'
  shim:
    jquery:
      exports: 'jQuery'
    backbone:
      # These script dependencies should be loaded before loading
      # backbone.js
      deps: ['underscore', 'jquery']
      # Once loaded, use the global 'Backbone' as the module value.
      exports: 'Backbone'
    jquery_ui:
      deps: ['jquery']
    underscore:
      exports: '_'
    marionette:
      deps: ['jquery', 'underscore', 'backbone']
      exports: 'Marionette'
    handlebars:
      exports: 'Handlebars'
    templates:
      deps: ['handlebars']
      exports: 'JST'
    backboneassociations:
      deps: ['backbone']
    backboneprojections:
      deps: ['backbone']
      exports: 'BackboneProjections'
    swag:
      deps: ['handlebars']
      exports: 'Swag'
    stickit:
      depts: ['jquery', 'backbone']
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
    backbonefetchcache:
      deps: ['underscore', 'backbone', 'jquery']
    select2:
      deps: ['jquery']
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
