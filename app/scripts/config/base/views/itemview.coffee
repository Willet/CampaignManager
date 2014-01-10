define ['app', 'marionette'], (App, Marionette) ->
  'use strict';

  ###
  base class with default events
  ###
  class App.Views.ItemView extends Marionette.ItemView
    template: false

    triggers:
      "click .remove": "remove"

    # @override
    bindings: null

    serializeData: ->
      @model?.viewJSON() || {}

    # support stickit bindings: call super() if subclass has its own onRender
    onRender: ->
      if @model and @bindings
        @stickit()

  ###
  ItemView inside a CollectionView
  ###
  class App.Views.ListItemView extends App.Views.ItemView
    tagName: 'li'
