define [
  "marionette",
  "../views",
  "backbone.stickit"
], (Marionette, Views) ->

  class Views.PageIndex extends Marionette.Layout

    template: "page/index"

    regions:
      'list': ".list"

    events:
      'change select.sort-order': 'updateSortBy'
      'keyup input#js-page-search': 'filterPages'

    triggers:
      "click #new-page": "new-page"
      "click #edit-most-recent": "edit-most-recent"

    updateSortBy: (event) ->
      order = @$(event.currentTarget).val()
      @trigger('change:sort-order', order)

    filterPages: (event) ->
      @trigger('change:filter', @$(event.currentTarget).val())

    serializeData: ->
      return {
        pages: @collection.toJSON()
        'store-id': @options['store-id']
      }

    initialize: (opts) ->
      @collection = @model

    onShow: ->
      @trigger('change:sort-order', 'last-modified')
      @list.show(new Views.PageIndexList(model: @collection))

  class Views.PageIndexList extends Marionette.ItemView

    template: "page/index_list"

    serializeData: ->
      return {
        pages: @model.toJSON()
      }

    initialize: ->
      @model.on "reset", => @render()
      @model.on "sort", => @render()

  Views
