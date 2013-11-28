define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    fetchContent: (store_id, content, params = {}) ->
      content.store_id = store_id
      content.url = "#{App.API_ROOT}/store/#{store_id}/content/#{content.get('id')}"
      unless content.isFetched # don't fetch multiple times
        content.fetch
          reset: true
          data: params
      content

    getContent: (store, content_id, params = {}) ->
      content = new Entities.Content({id: content_id, 'store-id': store.get('id')})
      content.store_id = store.get('id')
      content.url = "#{App.API_ROOT}/store/#{store_id}/content/#{content_id}"
      unless content.isFetched # don't fetch multiple times
        content.fetch
          reset: true
          data: params
      content

    getContents: (store_id, params = {}) ->
      contents = new Entities.ContentPageableCollection()
      contents.store_id = store_id
      contents.url = "#{App.API_ROOT}/store/#{store_id}/content"
      contents.setFilter(params)
      contents.getNextPage()
      contents

    getPageContents: (store_id, page_id, params = {}) ->
      content = new Entities.TileConfigCollection()
      content.store_id = store_id
      content.page_id = page_id
      content.url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/tile-config"
      content.setFilter(template: 'content')
      content.getNextPage()
      content

    getPageSuggestedContent: (store_id, page_id, params = {}) ->
      contents = new Entities.ContentPageableCollection()
      contents.store_id = store_id
      contents.page_id = page_id
      contents.url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/content/suggested"
      contents.getNextPage(params)
      contents

    getAllContentPage: (store_id, page_id, params = {}) ->
      contents = new Entities.ContentPageableCollection()
      contents.store_id = store_id
      contents.page_id = page_id
      contents.url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/content/all"
      contents.getNextPage()
      contents

    approveContent: (content, params) ->
      content.approve()

    rejectContent: (content, params) ->
      content.reject()

  App.reqres.setHandler "store:content",
    (store, params) ->
      API.getContents store.get('id'), params

  App.reqres.setHandler "content:get",
    (store, content, params) ->
      API.getContent store, content.get('id'), params

  App.reqres.setHandler "content:all",
    (store, params) ->
      API.getContents store.get('id'), params

  App.reqres.setHandler 'content:approve',
    (content, params) ->
      API.approveContent content, params

  App.reqres.setHandler 'content:reject',
    (content, params) ->
      API.rejectContent content, params

  App.reqres.setHandler "fetch:content",
    (store_id, content, params) ->
      API.fetchContent store_id, content, params

  App.reqres.setHandler "page:content",
    (page, params) ->
      API.getPageContents page.get('store-id'), page.get('id'), params

  App.reqres.setHandler "page:content:all",
    (page, params) ->
      API.getAllContentPage page.get('store-id'), page.get('id'), params

  App.reqres.setHandler "page:suggested_content",
    # handles App.request(^ that)
    (page, params) ->
      API.getPageSuggestedContent page.get('store-id'), page.get('id'), params
