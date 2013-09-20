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
        fields: [
          { var: "heroImageMobile", label: "Hero Image (Mobile)", type: "image" }
          { var: "legalCopy", label: "Legal Copy", type: "textarea" },
          { var: "facebookShare", label: "Facebook Share Copy", type: "text" },
          { var: "twitterShare", label: "Twitter Share Copy", type: "text" },
          { var: "emailShare", label: "Email Share Copy", type: "text" }
        ]
      }

    events:
      "click .layout-type": "selectLayoutType"

    selectLayoutType: (event) ->
      layoutClicked = @$(event.currentTarget)
      @$('#layout-types .layout-type').removeClass('selected')
      layoutClicked.addClass('selected')
      @trigger 'layout:selected', @extractClassSuffix(@$(event.currentTarget), 'js-layout')

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .layout").addClass("active")

    onShow: (opts) ->

  class Views.PageCreateProducts extends Marionette.Layout

    template: "pages_products"

    events:
      "click #add-url": "addUrl"
      "click #add-product": "addProduct"
      "keydown #url": "resetError"

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

    template: "_page_scrape_item"

    triggers:
      "click .remove": "remove"

    serializeData: ->
      @model.viewJSON()

  class Views.PageScrapeList extends Marionette.CollectionView

    itemView: Views.PageScrapeItem

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