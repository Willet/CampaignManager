define [
  'app',
  '../app',
  './layout_view'
], (App, PageManager, Views) ->

  PageManager.Layout ?= {}

  class PageManager.Layout.Controller extends App.Controllers.Base

    initialize: ->
      page = App.routeModels.get 'page'

      layout = new Views.PageCreateLayout
        model: page

      layout.on 'layout:selected', (newLayout) ->
        page.set 'layout', newLayout
        layout.render()

      layout.on 'save', () ->
        _.each layout.getFields(), (v, k) ->
          if v is ''
            v = null
          page.set k, v

        $.when(page.save()).done((data) ->
          App.navigate('/' + store.get('id') + '/pages/' + page.get('id') + '/products', { trigger: true })
        ).fail(() ->
          console.log arguments
        )

      @show layout
