define [
  "marionette",
  "../views",
  "backbone.stickit"
], (Marionette, Views) ->

  class Views.PageCreateProducts extends Marionette.Layout

    template: "page/products"

    events:
      "click #all-items": "allItems"
      "click #added-to-page": "addedToPage"

    triggers:
      "click .js-next": "save"

    addedToPage: (event) ->
      @trigger("display:added-to-page")

    allItems: (event) ->
      @trigger("display:all-items")

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    regions:
      "productList": "#product-list"

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .products").addClass("active")

    onShow: (opts) ->

  class Views.PageProductItem extends Marionette.ItemView

    template: "page/product_item"

  class Views.PageProductList extends Marionette.CollectionView

    itemView: Views.PageProductItem

  Views
