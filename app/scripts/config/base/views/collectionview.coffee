define ['app', 'marionette'], (App, Marionette) ->
  "use strict"

  ###
  Initialize with itemView (optional)
  ###
  class App.Views.CollectionView extends Marionette.CollectionView
    tagName: 'ul'
    template: false

    initialize: (options) ->
      @allSelected = false

    itemViewOptions: ->
      'selected': @allSelected
