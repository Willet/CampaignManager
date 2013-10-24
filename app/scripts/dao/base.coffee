define [
  "app"
], (App) ->

  class Base

    actions: []

    apiRoot: App.API_ROOT

    constructor: (options) ->

    _initializeActions: ->
      _.each @actions, (action) =>
        @[action] = _.partial(@_action, action) unless @[action]

    _action: (action, params = {}) ->
      $.getJSON(@url() + "/" + action, params)


  Base
