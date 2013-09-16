define [
  "marionette",
  "exports"
], (Marionette, Views) ->

  class Views.PageIndex extends Marionette.Layout

    template: "pages_index"

    serializeData: ->
      return {
        pages: @collection.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    initialize: (opts) ->
      @collection = @model

    onRender: (opts) ->

    onShow: (opts) ->

  class Views.PageCreateName extends Marionette.Layout

    template: "pages_name"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .main").addClass("active")

    onShow: (opts) ->

  class Views.PageCreateLayout extends Marionette.Layout

    template: "pages_layout"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .layout").addClass("active")

    onShow: (opts) ->

  class Views.PageCreateProducts extends Marionette.Layout

    template: "pages_products"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
        products: []
      }

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .products").addClass("active")

    onShow: (opts) ->

  class Views.PageCreateContent extends Marionette.Layout

    template: "pages_content"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    regions:
      "contentList": ".content > .list"

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .content").addClass("active")

    onShow: (opts) ->

  class Views.PagePreview extends Marionette.Layout

    template: "pages_view"

  Views