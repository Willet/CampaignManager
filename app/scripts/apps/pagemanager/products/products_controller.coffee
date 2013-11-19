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

    getProductListType: ->
      @productListType

    getProductList: (products) ->
      new Views.PageProductList
        collection: products
        itemView: @getProductListType()

    initialize: ->
      store = App.routeModels.get("store")
      page = App.routeModels.get("page")
      console.log page.attributes, store.attributes

      layout = new Views.PageCreateProducts(model: page)

      products = App.request("page:products", page)
      @setProductListType Views.PageProductGridItem

      #App.execute "when:fetched", products, ->
      #  # for each product, fetch their default content image
      #  products.collect (product) ->
      #    if product.get('default-image-id')
      #      App.request "fetch:content", store.get('id'), product.get("default-image-id")

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
        layout.productList.show @getProductList(products)

      layout.on "list-view", =>
        @setProductListType Views.PageProductListItem
        layout.productList.show @getProductList(products)

      layout.on "change:filter", ->
        filter = layout.extractFilter()
        products.setFilter filter

      layout.on "display:all-product", =>
        products = App.request "store:products", store, { filter: layout.extractFilter() }
        layout.productList.show @getProductList(products)

      layout.on "display:import-product", =>
        products = App.request "store:products", store, { filter: layout.extractFilter() }
        # TODO: products = App.request "page:products:imported", page, { filter: layout.extractFilter() }
        layout.productList.show @getProductList(products)

      layout.on "display:added-product", =>
        products = App.request "page:products", page, { filter: layout.extractFilter() }
        layout.productList.show @getProductList(products)

      layout.on "save", ->
        # TODO: there should be a better way to do this...
        $.when(page.save()).done (data) ->
          store = data["store-id"]
          page = data.id
          App.navigate "/" + store + "/pages/" + page + "/content",
            trigger: true

      @listenTo layout, 'show', =>
        layout.productList.show @getProductList(products)

      @show layout
