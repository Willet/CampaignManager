define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

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

    addContent: (store_id, page_id, content_id, params = {}) ->
      url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/content/#{content_id}"
      $.ajax url, type: "PUT"

    prioritizeContent: (store_id, page_id, content_id, params = {}) ->
      url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/content/#{content_id}/prioritize"
      $.ajax url, type: "POST"

    addAllContent: (store_id, page_id, content_list, params = {}) ->
      url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/content/add_all"
      $.ajax url, type: "PUT", data: JSON.stringify(content_list)

    removeContent: (store_id, page_id, content_id, params = {}) ->
      url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/content/#{content_id}"
      $.ajax url, type: "DELETE"

    addProduct: (store_id, page_id, product_id, params = {}) ->
      url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/product/#{product_id}"
      $.ajax url, type: "PUT"

    prioritizeProduct: (store_id, page_id, product_id, params = {}) ->
      url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/product/#{product_id}/prioritize"
      $.ajax url, type: "POST"

    removeProduct: (store_id, page_id, product_id, params = {}) ->
      url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/product/#{product_id}"
      $.ajax url, type: "DELETE"

    publishPage: (page, options) ->
      # TODO: move static_pages API under /graph/v1. ain't nobody got time for that today
      # TODO: this will not work in production?
      baseUrl = App.API_ROOT.replace('/graph/v1', '/static_pages').replace(':9000', ':8000');
      storeId = page.get('store-id')
      pageId = page.get('id')
      req = $.ajax({
        url: baseUrl + '/' + storeId + '/' + pageId + '/regenerate',
        type: 'POST',
        dataType: 'jsonp'
        })
      return req


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

  #
  # Page - Content Methods
  #

  App.reqres.setHandler "page:add_content",
    (page, content, options) ->
      API.addContent page.get('store-id'), page.get('id'), content.get('id')

  App.reqres.setHandler "page:add_all_content",
    (page, content_list, options) ->
      API.addAllContent page.get('store-id'), page.get('id'), content_list

  App.reqres.setHandler "page:remove_content",
    (page, content, options) ->
      API.removeContent page.get('store-id'), page.get('id'), content.get('id')

  App.reqres.setHandler "page:prioritize_content",
    (page, content, options) ->
      API.prioritizeContent page.get('store-id'), page.get('id'), content.get('id')

  #
  # Page - Product Methods
  #

  App.reqres.setHandler "page:add_product",
    (page, product, options) ->
      API.addProduct page.get('store-id'), page.get('id'), product.get('id')

  App.reqres.setHandler "page:remove_product",
    (page, product, options) ->
      API.removeProduct page.get('store-id'), page.get('id'), product.get('id')

  App.reqres.setHandler "page:prioritize_product",
    (page, product, options) ->
      API.prioritizeProduct page.get('store-id'), page.get('id'), product.get('id')
