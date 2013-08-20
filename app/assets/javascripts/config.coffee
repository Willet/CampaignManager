requirejs.config(
    # Remember: only use shim config for non-AMD scripts,
    # scripts that do not already call define(). The shim
    # config will not work correctly if used on AMD scripts,
    # in particular, the exports and init config will not
    # be triggered, and the deps config will be confusing
    # for those cases.

  paths:
    backbone: 'backbone-min'
    underscore: 'underscore'
    jquery: '//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min'
    marionette: 'backbone.marionette'
    handlebars: 'handlebars'
  shim:
    jquery:
      exports: 'jQuery'
    backbone:
      # These script dependencies should be loaded before loading
      # backbone.js
      deps: ['underscore', 'jquery']
      # Once loaded, use the global 'Backbone' as the module value.
      exports: 'Backbone'
    underscore:
      exports: '_'
    marionette:
      deps: ['jquery', 'underscore', 'backbone']
      export: 'Marionette'
    handlebars:
      export: 'Handlebars'
)

