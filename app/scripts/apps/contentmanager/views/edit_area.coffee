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

    onShow: ->
      @taggedProducts.show(new Views.TaggedProductInput(model: @model))
      @taggedPages.show(new Views.TaggedPagesInput(model: @model))
      @relayEvents(@taggedProducts.currentView, 'tagged-products')
      @relayEvents(@taggedPages.currentView, 'tagged-pages')

    onRender: ->

    onClose: ->

  Views
