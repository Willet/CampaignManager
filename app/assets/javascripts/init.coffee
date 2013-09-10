require [
  "app",
  "backbone",
  "marionette",
  "handlebars",
  "swag",
  "jquery",
  "underscore",
  "foundation",
  "templates",
  "apps/contentmanager/app",
  "apps/pageswizard/app"
], (App, Backbone, Marionette, Handlebars, Swag, $, _, Foundation, JST) ->

  # Handle Unauthorized (Redirect to login, etc...)
  redirectToLogin = ->
    locationhref = "#{window.appRoot}login"
    if (location.hash && location.hash.length > 0)
      locationhref += "?r=" + location.hash.substring(1)
    location.href = locationhref

  $(document).ajaxError((event, xhr) ->
    if (xhr.status == 401)
      redirectToLogin()
  )

  # TODO: REMOVE (already in config)
  Backbone.Model.prototype.toJSON = (opts) ->
    _.omit(@attributes, @blacklist || {})

  # Add additonal handlebars helpers
  Swag.registerHelpers(Handlebars)

  $().ready(-> App.start(); console.log App)
