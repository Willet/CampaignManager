require [
  "marionette"
], (Marionette) ->

  _.extend Backbone.Marionette.Application::,

    baseURI: ""

    navigate: (route, options = {}) ->
      Backbone.history.navigate route, options

    getCurrentRoute: ->
      frag = Backbone.history.fragment
      if _.isEmpty(frag) then null else frag

    startHistory: ->
      if Backbone.history && !Backbone.history.start(pushState: true, root: @baseURI)
        Backbone.history.start()

    # Handle Unauthorized (Redirect to login, etc...)
    redirectToLogin = ->
      @navigate("@{baseURI}login?r=#{window.location.hash}")