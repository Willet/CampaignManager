define ["marionette"], (Marionette) ->
  class Index extends Marionette.ItemView

    template: "products_index"

    serializeData: -> @model.viewJSON()

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  class Show extends Marionette.ItemView

    template: "products_show"

    events:
      "click .js-save": "saveContent"

    serializeData: -> @model.viewJSON()

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

    saveContent: (events) ->
      data = @$('form').serializeObject()
      @model.save(data)
      false

  {
    Index: Index
    Show: Show
  }
