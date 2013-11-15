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
      contents = new Entities.ContentPageableCollection()
      contents.store_id = store_id
      contents.page_id = page_id
      contents.url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/content"
      contents.getNextPage(params)
      contents

  App.reqres.setHandler "store:content",
    (store, params) ->
      API.getContents store.get('id'), params

  App.reqres.setHandler "content:get",
    (store, content, params) ->
      API.getContent store, content.get('id'), params

  App.reqres.setHandler "content:all",
    (store, params) ->
      API.getContents store.get('id'), params

  App.reqres.setHandler "fetch:content",
    (store_id, content, params) ->
      API.fetchContent store_id, content, params

  App.reqres.setHandler "page:content",
    (page, params) ->
      API.getPageContents page.get('store-id'), page.get('id'), params

