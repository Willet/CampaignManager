define [
  'app',
  '../app',
  './products_view'
], (App, PageManager, Views) ->

  PageManager.Products ?= {}

  class PageManager.Products.Controller extends App.Controllers.Base

    productListType: Views.PageProductGridItem

    setProductListType: (viewType) ->
      @productListType = viewType

    getProductListViewType: ->
      @productListType

    getProductListView: (products) ->
      new Views.PageProductList
        collection: products
        itemView: @getProductListViewType()

    # TODO: an idea, so it is more like sub-page switching
    #       maybe a router mechanism to handle this as well???
    #       real question is how do you still be DRY
    #       maybe instead the View (getProductListView)
    #       switches on the Type, in order to build the
    #       correct view ? instead of the view
    #       itself determing how it is layered together
    getImportListView: (products) -> null
    getAllListView: (products) -> null
    getAddedListView: (products) -> null

    initialize: ->
      store = App.routeModels.get("store")
      page = App.routeModels.get("page")

      layout = new Views.PageCreateProducts(model: page)

      products = App.request("page:products", page)
      @setProductListType Views.PageProductGridItem

      layout.on "select-all", ->
        products.collect (model) ->
          model.set "selected", true

      layout.on "added-product", (productData) ->
        newProduct = new Entities.Product(productData)
        # reload list
        layout.trigger "display:added-to-page"
        # also change the tab UI
        layout.$("#added-to-page").click()

      layout.on "product_list:itemview:remove", (listView, itemView) ->
        product = itemView.model
        App.request "page:add_product", page, product

      layout.on "product_list:itemview:remove", (listView, itemView) ->
        product = itemView.model
        App.request "page:remove_product", page, product

      layout.on "product_list:itemview:preview_product", (listView, itemView) ->
        product = itemView.model
        App.modal.show new Views.PageCreateProductPreview(model: product)

      layout.on "grid-view", =>
        @setProductListType Views.PageProductGridItem
        layout.productList.show @getProductListView(products)

      layout.on "list-view", =>
        @setProductListType Views.PageProductListItem
        layout.productList.show @getProductListView(products)

      layout.on "change:filter", ->
        filter = layout.extractFilter()
        products.setFilter filter

      layout.on "display:all-product", =>
        console.log "ALL"
        products = App.request "page:products:all", page, { filter: layout.extractFilter() }
        layout.productList.show @getProductListView(products)

      layout.on "display:import-product", =>
        products = App.request "store:products", store, { filter: layout.extractFilter() }
        # TODO: products = App.request "page:products:imported", page, { filter: layout.extractFilter() }
        layout.productList.show @getProductListView(products)

      layout.on "display:added-product", =>
        products = App.request "page:products", page, { filter: layout.extractFilter() }
        layout.productList.show @getProductListView(products)

      layout.on "save", ->
        # TODO: there should be a better way to do this...
        $.when(page.save()).done (data) ->
          App.navigate "/" + store.get('id') + "/pages/" + page.get('id') + "/content",
            trigger: true

      @listenTo layout, 'show', =>
        layout.productList.show @getProductListView(products)

      @show layout
