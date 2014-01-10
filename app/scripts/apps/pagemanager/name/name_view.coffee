define [
  'app',
  '../views',
  'backbone',
  'backbone.stickit'
], (App, Views, Backbone, Stickit) ->

  class Views.Name extends App.Views.Layout

    template: "page/name"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
        store: @store.toJSON()
      }

    triggers:
      "click .js-next": "save"

    # handled by backbone.stickit
    bindings:
      'input[name=name]':
        observe: 'name'
        events: ['blur']
      'input[name=url]':
        observe: 'url'
        events: ['blur']

    initialize: (opts) ->
      @store = opts['store']

    onShow: (opts) ->

  Views
