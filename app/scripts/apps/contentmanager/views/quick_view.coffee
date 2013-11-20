define [
  'app',
  'entities',
  '../views',
], (App, Entities, Views) ->

  class Views.ContentQuickView extends App.Views.ItemView

    template: "content/quick_view"

    serializeData: -> @model.viewJSON()

  Views
