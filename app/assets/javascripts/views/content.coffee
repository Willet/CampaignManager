define ["marionette", "models/content"], (Marionette, Content) ->

  class Index extends Marionette.Layout

    id: 'content-index'

    template: "content_index"

    serializeData: -> @model.viewJSON()

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  class Show extends Marionette.Layout

    template: "content_show"

    events:
      "click .js-save": "saveContent"
      "click .js-approve": "approveContent"
      "click .js-reject": "rejectContent"

    serializeData: -> @model.viewJSON()

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

    rejectContent: (event) ->
      @model.reject()

    approveContent: (event) ->
      @model.approve()

    saveContent: (event) ->
      data = @$('form').serializeObject()
      @model.save(data)
      false

  # declare exports
  return {
    Index: Index
    Show: Show
  }


