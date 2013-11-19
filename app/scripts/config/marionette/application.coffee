require [
  "marionette",
  "jquery"
], (Marionette, $) ->

  # :: === .prototype
  _.extend Backbone.Marionette.Application::,

    APP_ROOT: "/"

    # alias: App.navigate
    navigate: (route, options = {}) ->
      $(window).scrollTop(0)
      Backbone.history.navigate route, options

    getCurrentRoute: ->
      frag = Backbone.history.fragment
      if _.isEmpty(frag) then null else frag

    register: (instance, id) ->
      @_registry ?= {}
      @_registry[id] = instance

    unregister: (instance, id) ->
      delete @_registry[id]

    resetRegistry: ->
      oldCount = @getRegistrySize()
      for key, controller of @_registry
        controller.region.close()
      msg = "There were #{oldCount} controllers in the registry, now are #{@getRegistrySize()}"
      if @getRegistrySize() > 0 then console.warn(msg, @_registry) else console.log(msg)

    getRegistrySize: ->
      _.size @_registry

    startHistory: ->
      if Backbone.history && !Backbone.history.start(pushState: false, root: @APP_ROOT)
        @navigate("notFound", trigger: false)

    setTitle: (title) ->
      App.titlebar.currentView.model.set(title: title)
      App.header.currentView.model.set(page: title)

