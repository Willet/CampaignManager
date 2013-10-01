require [
  "marionette",
  "jquery"
], (Marionette, $) ->

  _.extend Backbone.Marionette.Application::,

    APP_ROOT: "/"

    navigate: (route, options = {}) ->
      $(window).scrollTop(0)
      Backbone.history.navigate route, options

    getCurrentRoute: ->
      frag = Backbone.history.fragment
      if _.isEmpty(frag) then null else frag

    startHistory: ->
      if Backbone.history && !Backbone.history.start(pushState: true, root: @APP_ROOT)
        @navigate("notFound", trigger: false)

    setTitle: (title) ->
      App.titlebar.currentView.model.set(title: title)
      App.header.currentView.model.set(page: title)

    show: (view) ->
      @main.show(view)

