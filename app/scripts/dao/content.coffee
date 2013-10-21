define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    getContent: (store_id, content_id, params = {}) ->
      contents = new Entities.Content(id: content_id, 'store-id': store_id)
      contents.url = "#{App.API_ROOT}/store/#{store_id}/content/#{content_id}"
      unless content.isNew # don't fetch multiple times
        contents.fetch
          reset: true
          data: params
      contents

    getContents: (store_id, params = {}) ->
      contents = new Entities.ContentCollection()
      contents.url = "#{App.API_ROOT}/store/#{store_id}/content"
      contents.fetch
        reset: true
        data: params
      contents

    getPagedContents: (store_id, params = {}) ->
      contents = new Entities.ContentPageableCollection()
      contents.url = "#{App.API_ROOT}/store/#{store_id}/content"
      contents.getNextPage()
      contents

    getAddedToPagePagedContents: (store_id, page_id, params = {}) ->
      contents = new Entities.ContentPageableCollection()
      contents.url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/content"
      contents.getNextPage()
      contents

  App.reqres.setHandler "content:entities",
    (store_id, params) ->
      API.getContents store_id, params

  App.reqres.setHandler "content:entities:paged",
    (store_id, params) ->
      API.getPagedContents store_id, params

  App.reqres.setHandler "added-to-page:content:entities:paged",
    (store_id, page_id, params) ->
      API.getAddedToPagePagedContents store_id, page_id, params

  App.reqres.setHandler "content:entity",
    (store_id, content_id, params) ->
      API.getContent store_id, content_id, params

