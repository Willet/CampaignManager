define [
  "marionette",
  "entities",
  "../views"
], (Marionette, Entities, Views) ->

  class Views.ContentEditArea extends Marionette.Layout

    template: "content/edit_item"

    serializeData: -> _.extend(@model.viewJSON(), @actions)

    regions:
      "taggedProducts": ".js-tagged-products"
      "taggedPages": ".js-tagged-pages"

    triggers:
      "click .js-approve": "content:approve"
      "click .js-reject": "content:reject"
      "click .js-undecided": "content:undecided"

    initialize: (options) ->
      @actions = options['actions']
      @multiEdit = options['multiEdit']

    onShow: ->

    onRender: ->
      taggedProductInputConfig = model: @model, store: @store
      taggedPagesInputConfig = model: @model, store: @store

      if @multiEdit
          taggedProductInputConfig['collection'] = @model
          taggedProductInputConfig['store_id'] = @actions['store_id']
          delete taggedProductInputConfig['model']

          taggedPagesInputConfig['collection'] = @model
          taggedPagesInputConfig['store_id'] = @actions['store_id']
          delete taggedPagesInputConfig['model']


      @taggedProducts.show(new Views.TaggedProductInput(taggedProductInputConfig))
      @taggedPages.show(new Views.TaggedPagesInput(taggedPagesInputConfig))
      @relayEvents(@taggedProducts.currentView, 'tagged-products')
      @relayEvents(@taggedPages.currentView, 'tagged-pages')

    onClose: ->

  Views
