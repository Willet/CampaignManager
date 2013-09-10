require [
  "app",
  "backbone",
  "marionette",
  "jquery",
  "underscore",
  # sub modules to load, they attach to the application
  "apps/contentmanager/app",
  "apps/pageswizard/app"
], (App, Backbone, Marionette, $, _) ->

  # Handle Unauthorized (Redirect to login, etc...)
  redirectToLogin = ->
    locationhref = "#{App.appRoot}login"
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

  $().ready(-> App.start())
