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
    backboneassociations: 'backbone-associations-min'
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
    backboneassociations:
      deps: ['backbone']
    swag:
      deps: ['handlebars']
      exports: 'Swag'
)

require ["secondfunnel", "app", "marionette", "handlebars", "swag", "jquery", "underscore", "templates"], (SecondFunnel, App, Marionette, Handlebars, Swag, $, _, JST) ->

  # Handle Unauthorized (Redirect to login, etc...)
  redirectToLogin = ->
    locationhref = "/login"
    if (location.hash && location.hash.length > 0)
      locationhref += "?r=" + location.hash.substring(1)
    location.href = locationhref
  $(document).ajaxError((event, xhr) ->
    if (xhr.status == 401)
      redirectToLogin()
  )


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
      document.body.scrollTop = 0

      return false

  $.fn.serializeObject = ->

    json = {}
    push_counters = {}
    patterns =
      validate  : /^[a-zA-Z][a-zA-Z0-9_]*(?:\[(?:\d*|[a-zA-Z0-9_]+)\])*$/,
      key       : /[a-zA-Z0-9_]+|(?=\[\])/g,
      push      : /^$/,
      fixed     : /^\d+$/,
      named     : /^[a-zA-Z0-9_]+$/

    @build = (base, key, value) ->
      base[key] = value
      base

    @push_counter = (key) ->
      push_counters[key] = 0 if push_counters[key] is undefined
      push_counters[key]++

    $.each $(@).serializeArray(), (i, elem) =>
      return unless patterns.validate.test(elem.name)

      keys = elem.name.match patterns.key
      merge = elem.value
      reverse_key = elem.name

      while (k = keys.pop()) isnt undefined

        if patterns.push.test k
          re = new RegExp("\\[#{k}\\]$")
          reverse_key = reverse_key.replace re, ''
          merge = @build [], @push_counter(reverse_key), merge

        else if patterns.fixed.test k
          merge = @build [], k, merge

        else if patterns.named.test k
          merge = @build {}, k, merge

      json = $.extend true, json, merge

    return json

  $().ready(-> App.start())
