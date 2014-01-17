define [
  'app',
  'marionette'
], (App, Marionette) ->

  # A base controller the registers itself to the application
  # and unregisters itself on close, useful for
  # determining memory leaks etc
  # also has the ability to show a loading view
  class App.Controllers.Base extends Marionette.Controller

    constructor: (options = {}) ->
      @region = options.region or App.request 'default:region'
      @_instance_id = _.uniqueId('controller')
      App.execute 'register:instance', @, @_instance_id
      super

    show: (view, options = {}) ->
      _.defaults options,
        loading: false
        region: @region

      @_setMainView view
      @_manageView view, options

    close: ->
      App.execute 'unregister:instance', @, @_instance_id
      super

    _setMainView: (view) ->
      return if @_mainView
      @_mainView = view
      @listenTo view, 'close', @close

    _manageView: (view, options) ->
      if options.loading
        App.execute 'show:loading', view, options
      else
        options.region.show view

  return App.Controllers
