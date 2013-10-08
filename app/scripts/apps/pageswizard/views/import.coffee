define [
  "marionette",
  "../views",
  "backbone.stickit"
], (Marionette, Views) ->

  class Views.PageImport extends Marionette.Layout

    template: "page/import"

    serializeData: ->
      return {
        page: @model.toJSON()
      }

    initialize: (opts) ->
      @listenTo(@model, "sync", => @render())

    onRender: (opts) ->

    onShow: (opts) ->

  Views
