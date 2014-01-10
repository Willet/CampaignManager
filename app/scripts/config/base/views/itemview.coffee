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

    initialize: ->
      if @model
        @model.on 'sync', =>
          @render()

    # support stickit bindings: call super() if subclass has its own onRender
    onRender: ->
      if @model and @bindings
        @stickit()

  ###
  ItemView inside a CollectionView
  ###
  class App.Views.ListItemView extends App.Views.ItemView
    tagName: 'li'


  ###
  A ListItemView that is meant to be selected as a whole
  ###
  class App.Views.SelectableListItemView extends App.Views.ListItemView
    # handled by backbone.stickit
    bindings:
      '.js-selected':
        attributes: [
          name: 'checked'
          observe: 'selected'
          onGet: (observed) ->
            if observed then true else false
        ]
      '.item':
        attributes: [
          name: 'class'
          observe: 'selected'
          onGet: (observed) ->
            if observed then "selected" else ""
        ]

    events:
      "click": "selectItem"

    selectItem: (event) ->
      @model.set('selected', !@model.get('selected'))
      @updateDOM()

    # @override
    updateDOM: () ->
      if @model
        if @model.get('selected')
          @$el.addClass('selected')
        else
          @$el.removeClass('selected')

    onRender: ->
      @updateDOM()
      super()
