define [
  "marionette",
  "../views",
  "backbone.stickit"
], (Marionette, Views) ->

  class Views.PageCreateProducts extends Marionette.Layout

    template: "page/products"

    events:
      "click #add-url": "addUrl"
      "click #add-product": "addProduct"
      "keydown #url": "resetError"

    triggers:
      "click .js-next": "save"

    resetError: (event) ->
      $(event.currentTarget).removeClass("error")

    validUrl: (url) ->
      # TODO: move this to the scrape model ?
      urlPattern = /(http|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/
      url && url != "" && urlPattern.test(url)

    addUrl: (event) ->
      if @validUrl(@$('#url').val())
        @trigger "new:scrape", @$('#url').val()
        @$('#url').val("")
      else
        @$('#url').addClass("error")
        # figure out what to do

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    regions:
      "scrapeList": "#scrape-list"
      "productList": "#product-list"

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .products").addClass("active")

    onShow: (opts) ->

  class Views.PageScrapeItem extends Marionette.ItemView

    template: "page/scrape_item"

    triggers:
      "click .remove": "remove"

    serializeData: ->
      @model.viewJSON()

  class Views.PageScrapeList extends Marionette.CollectionView

    itemView: Views.PageScrapeItem

  Views
