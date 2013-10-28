define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    fetchContent: (store_id, content, params = {}) ->
      content.store_id = store_id
      content.url = "#{App.API_ROOT}/store/#{store_id}/content/#{content.id}"
      unless content.isFetched # don't fetch multiple times
        content.fetch
          reset: true
          data: params
      content

    getContent: (store_id, content_id, params = {}) ->
      content = new Entities.Content({id: content_id, 'store-id': store_id})
      content.store_id = store_id
      content.url = "#{App.API_ROOT}/store/#{store_id}/content/#{content_id}"
      unless content.isFetched # don't fetch multiple times
        content.fetch
          reset: true
          data: params
      content

    getContents: (store_id, params = {}) ->
      contents = new Entities.ContentCollection()
      contents.store_id = store_id
      contents.url = "#{App.API_ROOT}/store/#{store_id}/content"
      contents.fetch
        reset: true
        data: params
      contents

    getPagedContents: (store_id, params = {}) ->
      contents = new Entities.ContentPageableCollection()
      contents.store_id = store_id
      contents.url = "#{App.API_ROOT}/store/#{store_id}/content"
      if store_id is "38"
        contents.setFilter({tags: 'backtoblue'})

      contents.getNextPage()
      contents

    getNeedsReviewPagedContents: (store_id, params = {}) ->
      contents = new Entities.ContentPageableCollection()
      contents.store_id = store_id
      contents.url = "#{App.API_ROOT}/store/#{store_id}/content"

      filters = active: true, approved: false

      if store_id is "38"
        filters['tags'] = 'backtoblue'

      contents.setFilter(filters)

      contents.getNextPage()
      contents

    getAddedToPagePagedContents: (store_id, page_id, params = {}) ->
      contents = new Entities.ContentPageableCollection()
      contents.store_id = store_id
      contents.page_id = page_id
      contents.url = "#{App.API_ROOT}/store/#{store_id}/page/#{page_id}/content"
      contents.getNextPage()
      contents

  App.reqres.setHandler "content:entities",
    (store_id, params) ->
      API.getContents store_id, params

  App.reqres.setHandler "content:entities:paged",
    (store_id, params) ->
      API.getPagedContents store_id, params

  App.reqres.setHandler "needs-review:content:entities:paged",
    (store_id, params) ->
      API.getNeedsReviewPagedContents store_id, params

  App.reqres.setHandler "added-to-page:content:entities:paged",
    (store_id, page_id, params) ->
      API.getAddedToPagePagedContents store_id, page_id, params

  App.reqres.setHandler "content:entity",
    (store_id, content_id, params) ->
      API.getContent store_id, content_id, params

  App.reqres.setHandler "fetch:content",
    (store_id, content, params) ->
      API.fetchContent store_id, content, params

