define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    getProduct: (store_id, product_id, params = {}) ->
      product = new Entities.Product()
      product.url = "#{App.API_ROOT}/store/#{store_id}/product/live/#{product_id}"
      product.fetch
        reset: true
        data: params
      product

    getProducts: (store_id, params = {}) ->
      products = new Entities.ProductCollection()
      products.url = "#{App.API_ROOT}/store/#{store_id}/product/live"
      products.fetch
        reset: true
        data: params
      products

    getProductsPaged: (store_id, params = {}) ->
      products = new Entities.ProductPageableCollection()
      products.url = "#{App.API_ROOT}/store/#{store_id}/product/live"
      products.getNextPage()
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
      products.getNextPage()
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

