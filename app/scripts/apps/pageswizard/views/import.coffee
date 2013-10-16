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
        product_sources: @product_sources.toJSON()
      }

    initialize: (opts) ->
      @product_sources = opts['product_sources']
      @listenTo(@model, "sync", => @render())

    onRender: (opts) ->

    onShow: (opts) ->

  class Views.PageScrapeItem extends Marionette.ItemView

    template: "page/scrape_item"

    triggers:
      "click .remove": "remove"

  class Views.PageScrapeList extends Marionette.CollectionView

    itemView: Views.PageScrapeItem

  Views
