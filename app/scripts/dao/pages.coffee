define [
  "app",
  "dao/base",
  "entities",
  "underscore"
], (App, Base, Entities, _) ->

  API =
    getPage: (store_id, page_id, params = {}) ->
      page = new Entities.Page({ id: page_id, 'store-id': store_id })
      page.url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}"
      page.fetch
        reset: true
        data: params
      page

    getPages: (store_id, params = {}) ->
      pages = new Entities.PageCollection()
      pages.store_id = store_id
      pages.url = "#{App.API_ROOT}/store/#{store_id}/page"
      pages.fetch
        reset: true
        data: params
      pages

    newPage: (store_id, params = {}) ->
      page = new Entities.Page(params)
      page.set('store-id', store_id)
      page.url = -> "#{App.API_ROOT}/store/#{store_id}/page/#{@get('id') || ""}"
      page

    addContent: (page, content, params = {}) ->
      url = "#{App.API_ROOT}/store/#{page.get('store-id')}/page/#{page.get('id')}/content/#{content.get('id')}"
      content.save({}, { method: 'PUT', url: url })

    removeContent: (page, content, params = {}) ->
      url = "#{App.API_ROOT}/store/#{page.get('store-id')}/page/#{page.get('id')}/content/#{content.get('id')}"
      content.save({}, { method: 'DELETE', url: url })

    prioritizeContent: (page, content, params = {}) ->
      url = "#{App.API_ROOT}/store/#{page.get('store-id')}/page/#{page.get('id')}/content/#{content.get('id')}/prioritize"
      content.save({}, { method: 'POST', url: url })

    deprioritizeContent: (page, content, params = {}) ->
      url = "#{App.API_ROOT}/store/#{page.get('store-id')}/page/#{page.get('id')}/content/#{content.get('id')}/deprioritize"
      content.save({}, { method: 'POST', url: url })

    addAllContent: (page, content_list, params = {}) ->
      _.each content_list, (content) =>
        @addContent page, content, params

    removeAllContent: (page, content_list, params = {}) ->
      _.each content_list, (content) =>
        @removeContent page, content, params

    addProduct: (page, product, params = {}) ->
      url = "#{App.API_ROOT}/store/#{page.get('store-id')}/page/#{page.get('id')}/product/#{product.get('id')}"
      product.save({}, { method: 'PUT', url: url })

    addAllProducts: (page, product_list, params = {}) ->
      _.each product_list, (product) =>
        @addProduct page, product, params

    removeProduct: (page, product, params = {}) ->
      url = "#{App.API_ROOT}/store/#{page.get('store-id')}/page/#{page.get('id')}/product/#{product.get('id')}"
      product.save({}, { method: 'DELETE', url: url })

    removeAllProducts: (page, product_list, params = {}) ->
      _.each product_list, (product) =>
        @removeProduct page, product, params

    prioritizeProduct: (page, product, params = {}) ->
      url = "#{App.API_ROOT}/store/#{page.get('store-id')}/page/#{page.get('id')}/product/#{product.get('id')}/prioritize"
      product.save({}, { method: 'POST', url: url })

    deprioritizeProduct: (page, product, params = {}) ->
      url = "#{App.API_ROOT}/store/#{page.get('store-id')}/page/#{page.get('id')}/product/#{product.get('id')}/deprioritize"
      product.save({}, { method: 'POST', url: url })

    publishPage: (page, options) ->
      # TODO: move static_pages API under /graph/v1. ain't nobody got time for that today
      # TODO: this will not work in production?
      baseUrl = App.API_ROOT.replace('/graph/v1', '/static_pages')
      storeId = page.get('store-id')
      pageId = page.get('id')

      ops = new $.Deferred()

      $.when(
        $.ajax(
          url: "#{App.API_ROOT}/store/#{storeId}/intentrank/#{pageId}/"
          type: 'POST'
          dataType: 'jsonp'
        ),
        $.ajax(
          url: "#{baseUrl}/#{storeId}/#{pageId}/regenerate"
          type: 'POST'
          dataType: 'jsonp'
        )
      ).done((wat) =>
        ops.resolve wat
      )

      ops

    transferPage: (page, store, options) ->
      storeId = page.get('store-id')
      pageId = page.get('id')

      $.ajax
        url: "#{App.API_ROOT}/store/#{storeId}/page/#{pageId}/transfer"
        type: 'POST'
        dataType: 'json'


  App.reqres.setHandler "page:all",
    (store, options) ->
      API.getPages store.get('id'), options

  App.reqres.setHandler "page:get",
    (params, options) ->
      if params['page_id'] == 'new'
        API.newPage params['store_id'], options
      else
        API.getPage params['store_id'], params['page_id'], options

  App.reqres.setHandler "page:new",
    (params, options) ->
      API.newPage params['store_id'], options

  App.reqres.setHandler 'page:publish', (page, options) ->
    API.publishPage page, options

  App.reqres.setHandler 'page:transfer', (page, store) ->
    API.transferPage page, store

  #
  # Page - Content Methods
  #

  App.reqres.setHandler "page:add_content",
    (page, content, options) ->
      API.addContent page, content, options

  App.reqres.setHandler "page:add_all_content",
    (page, content_list, options) ->
      API.addAllContent page, content_list, options

  App.reqres.setHandler "page:remove_content",
    (page, content, options) ->
      API.removeContent page, content, options

  App.reqres.setHandler "page:remove_all_content",
    (page, content_list, options) ->
      API.removeAllContent page, content_list, options

  App.reqres.setHandler "page:prioritize_content",
    (page, content, options) ->
      API.prioritizeContent page, content, options

  App.reqres.setHandler "page:deprioritize_content",
    (page, content, options) ->
      API.deprioritizeContent page, content, options

  #
  # Page - Product Methods
  #

  App.reqres.setHandler "page:add_product",
    (page, product, options) ->
      API.addProduct page, product, options

  App.reqres.setHandler "page:add_all_products",
    (page, product_list, options) ->
      API.addAllProducts page, product_list, options

  App.reqres.setHandler "page:remove_product",
    (page, product, options) ->
      API.removeProduct page, product, options

  App.reqres.setHandler "page:remove_all_products",
    (page, product_list, options) ->
      API.removeAllProducts page, product_list, options

  App.reqres.setHandler "page:prioritize_product",
    (page, product, options) ->
      API.prioritizeProduct page, product, options

  App.reqres.setHandler "page:deprioritize_product",
    (page, product, options) ->
      API.deprioritizeProduct page, product, options
