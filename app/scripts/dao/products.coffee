define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    fetchProduct: (store_id, product, params = {}) ->
      product.store_id = store_id
      product.url = "#{App.API_ROOT}/store/#{store_id}/product/live/#{product.get('id')}"
      unless product.isFetched # don't fetch multiple times
        product.fetch
          reset: true
          data: params
      product

    getProduct: (store_id, product_id, params = {}) ->
      product = new Entities.Product(id: product_id, 'store-id': store_id)
      product.store_id = store_id
      product.url = "#{App.API_ROOT}/store/#{store_id}/product/live/#{product_id}"
      unless product.isFetched # don't fetch multiple times
        product.fetch
          reset: true
          data: params
      product

    getProducts: (store_id, params = {}) ->
      products = new Entities.ProductCollection()
      products.store_id = store_id
      products.url = "#{App.API_ROOT}/store/#{store_id}/product/live"
      products.fetch
        reset: true
        data: params
      products

    getProductsPaged: (store_id, params = {}) ->
      products = new Entities.ProductPageableCollection()
      products.store_id = store_id
      products.url = "#{App.API_ROOT}/store/#{store_id}/product/live"

      filters = {}

      if store_id is "38"
        filters['tags'] = 'backtoblue'

      products.setFilter(filters, false)

      #products.getNextPage()
      products.fetchAll()
      products

    getProductSet: (store_id, product_ids, params = {}) ->
      products = new Entities.ProductCollection(_.map(product_ids, (id) -> {'id': id, 'store-id': store_id}))
      if products.size() > 0
        products.url = "#{App.API_ROOT}/store/#{store_id}/product/live"
        products.fetch
          reset: false
          data: _.extend(id: product_ids, params)
      products

    # DEFER: decide on where to put related models etc
    getPageProducts: (store_id, page_id, params = {}) ->
      products = new Entities.ProductPageableCollection()
      products.url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/product"
      #products.getNextPage()
      products.fetchAll()
      products

  App.reqres.setHandler "product:entities:set",
    (store_id, product_ids, params) ->
      API.getProductSet store_id, product_ids, params

  App.reqres.setHandler "product:entities",
    (store_id, params) ->
      API.getProducts store_id, params

  App.reqres.setHandler "product:entities:paged",
    (store_id, params) ->
      API.getProductsPaged store_id, params

  App.reqres.setHandler "added-to-page:product:entities:paged",
    (store_id, page_id, params) ->
      API.getPageProducts store_id, page_id, params

  App.reqres.setHandler "product:entity",
    (store_id, product_id, params) ->
      API.getProduct store_id, product_id, params

  App.reqres.setHandler "fetch:product",
    (store_id, product, params) ->
      API.fetchProduct store_id, product, params
