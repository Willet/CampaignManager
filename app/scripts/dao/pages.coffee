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

    addAllContent: (store_id, page_id, content_list, params = {}) ->
      url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/content/add_all"
      $.ajax url, type: "PUT", data: JSON.stringify(content_list)

    addProduct: (page, product, params = {}) ->
      url = "#{App.API_ROOT}/store/#{page.get('store-id')}/page/#{page.get('id')}/product/#{product.get('id')}"
      product.save({}, { method: 'PUT', url: url })

    removeProduct: (page, product, params = {}) ->
      url = "#{App.API_ROOT}/store/#{page.get('store-id')}/page/#{page.get('id')}/product/#{product.get('id')}"
      product.save({}, { method: 'DELETE', url: url })

    prioritizeProduct: (page, product, params = {}) ->
      url = "#{App.API_ROOT}/store/#{page.get('store-id')}/page/#{page.get('id')}/product/#{product.get('id')}/prioritize"
      product.save({}, { method: 'POST', url: url })

    deprioritizeProduct: (page, product, params = {}) ->
      url = "#{App.API_ROOT}/store/#{page.get('store-id')}/page/#{page.get('id')}/product/#{product.get('id')}/deprioritize"
      product.save({}, { method: 'POST', url: url })

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
      API.addContent page, content, options

  App.reqres.setHandler "page:add_all_content",
    (page, content_list, options) ->
      API.addAllContent page.get('store-id'), page.get('id'), content_list

  App.reqres.setHandler "page:remove_content",
    (page, content, options) ->
      API.removeContent page, content, options

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

  App.reqres.setHandler "page:remove_product",
    (page, product, options) ->
      API.removeProduct page, product, options

  App.reqres.setHandler "page:prioritize_product",
    (page, product, options) ->
      API.prioritizeProduct page, product, options

  App.reqres.setHandler "page:deprioritize_product",
    (page, product, options) ->
      API.deprioritizeProduct page, product, options
