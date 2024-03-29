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

    getProductLoadingView: (products) ->
      new Views.PageLoadingProduct
        collection: products

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
      categories = App.request "categories:store", store.get('id')

      App.execute 'when:fetched', categories, ->
        page.categories = _.clone categories.models

      layout = new Views.PageCreateProducts(model: page)

      products = App.request "page:products:all", page, layout.extractFilter()
      @setProductListType Views.PageProductGridItem

      layout.on "select-all", =>
        products.collect (model) ->
          model.set "selected", true
        layout.productList.show @getProductListView(products)

      layout.on 'select-none', =>
        products.collect (model) ->
          model.set "selected", false
        layout.productList.show @getProductListView(products)

      layout.on "added-product", (productData) ->
        newProduct = new Entities.Product(productData)
        # reload list
        layout.trigger "display:added-to-page"
        # also change the tab UI
        layout.$("#added-to-page").click()

      layout.on "product_list:itemview:add_product", (listView, itemView) ->
        product = itemView.model
        App.request "page:add_product", page, product

      layout.on "product_list:itemview:remove_product", (listView, itemView) ->
        product = itemView.model
        App.request "page:remove_product", page, product

      layout.on 'product_list:itemview:prioritize_product', (listView, itemView) ->
        product = itemView.model
        App.request 'page:prioritize_product', page, product

      layout.on 'product_list:itemview:deprioritize_product', (listView, itemView) ->
        product = itemView.model
        App.request 'page:deprioritize_product', page, product

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
        products.setFilter(filter)

      layout.on "change:tags", _.debounce((() ->
        layout.trigger('change:filter')), 1000)

      layout.on 'add-selected', () =>
        selected = products.filter (model) ->
          select = model.get('selected')
          if select
            model.set 'selected', false
          select

        App.request 'page:add_all_products', page, selected
        layout.productList.show @getProductListView(products)

      layout.on 'remove-selected', () =>
        selected = products.filter (model) ->
          select = model.get('selected')
          if select
            model.set 'selected', false
          select

        App.request 'page:remove_all_products', page, selected
        layout.productList.show @getProductListView(products)

      layout.on "display:all-product", =>
        products = App.request "page:products:all", page, layout.extractFilter()
        layout.productList.show @getProductListView(products)
        layout.loadingArea.show @getProductLoadingView(products)

      #layout.on "display:import-product", =>
      #  products = App.request "store:products", store, { filter: layout.extractFilter() }
      #  # TODO: products = App.request "page:products:imported", page, { filter: layout.extractFilter() }
      #  layout.productList.show @getProductListView(products)
      #  layout.loadingArea.show @getProductLoadingView(products)

      layout.on "display:added-product", =>
        products = App.request "page:products", page, layout.extractFilter()
        layout.productList.show @getProductListView(products)
        layout.loadingArea.show @getProductLoadingView(products)

      layout.on "save", ->
        # TODO: there should be a better way to do this...
        $.when(page.save()).done (data) ->
          App.navigate "/" + store.get('id') + "/pages/" + page.get('id') + "/content",
            trigger: true

      layout.on 'fetch:next-page', () ->
        products.getNextPage()

      @listenTo layout, 'show', =>
        layout.productList.show @getProductListView(products)
        layout.loadingArea.show @getProductLoadingView(products)

      @show layout
