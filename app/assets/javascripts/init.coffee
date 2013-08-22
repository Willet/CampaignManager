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
    marionette: 'lib/backbone.marionette'
    handlebars: 'handlebars'
    templates: '../templates/templates.pre.min'
    backbonerelational: 'backbone.relational'
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
      exports: 'Marionette'
    handlebars:
      exports: 'Handlebars'
    templates:
      deps: ['handlebars']
      exports: 'JST'
    backbonerelational:
      deps: ['backbone']
      exports: 'Backbone.Relational'
    swag:
      deps: ['handlebars']
      exports: 'Swag'
)

require ["secondfunnel", "app", "marionette", "handlebars", "swag", "jquery", "underscore", "templates"], (SecondFunnel, App, Marionette, Handlebars, Swag, $, _, JST) ->

  # Setup rendering to use JST given the template name
  Marionette.Renderer.render = (template, data) -> return JST[_.result(t: template, 't')](data)

  # Add additonal handlebars helpers
  Swag.registerHelpers(Handlebars)

  # Globally capture clicks. If they are internal and not in the pass
  # through list, route them through Backbone's navigate method.
  $(document).on "click", "a[href^='/']", (event) ->

    href = $(event.currentTarget).attr('href')

    # chain 'or's for other black list routes
    passThrough = href.indexOf('sign_out') >= 0

    # Allow shift+click for new tabs, etc.
    if !passThrough && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey
      event.preventDefault()

      # Remove leading slashes and hash bangs (backward compatablility)
      url = href.replace(/^\//,'').replace('\#\!\/','')

      # Instruct Backbone to trigger routing events
      SecondFunnel.router.navigate url, { trigger: true }

      return false
  $().ready(-> App.start())
