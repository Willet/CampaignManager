define ["marionette", "models/pages"], (Marionette, Pages) ->

  class Index extends Marionette.Layout

    template: "pages_index"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  class Name extends Marionette.Layout

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

  class Layout extends Marionette.Layout

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

  class Products extends Marionette.Layout

    template: "pages_products"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .products").addClass("active")

    onShow: (opts) ->

  class Content extends Marionette.Layout

    template: "pages_content"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .content").addClass("active")

    onShow: (opts) ->

  # declare exports
  return {
    Index: Index
    Name: Name
    Layout: Layout
    Products: Products
    Content: Content
  }


