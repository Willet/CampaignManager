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

    setTitle: (title) ->
      App.titlebar.currentView.model.set(title: title)
      App.header.currentView.model.set(page: title)

    show: (view) ->
      @main.show(view)

