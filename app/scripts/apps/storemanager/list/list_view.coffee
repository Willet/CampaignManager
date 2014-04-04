define [
  'app',
  '../views'
], (App, Views) ->

  class Views.StoreIndex extends App.Views.Layout
    template: "store/index"
    regions:
      list: '.list'

    initialize: (opts) ->
      @collection = @model

    serializeData: () ->
      stores: @model.toJSON()

    onShow: () ->
      @list.show new Views.StoreIndexList
        model: @collection

  class Views.StoreIndexList extends App.Views.ItemView
    template: "store/index_list"

    serializeData: () ->
      stores: @model.toJSON()

    initialize: (opts) ->
      self = this

      @model.on 'add', () ->
        self.render()

  Views
