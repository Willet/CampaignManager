define ['exports', 'app'], (Loading, App) ->
  "use strict"

  # ???
  class Loading.LoadingView extends App.Views.ItemView
    template: 'shared/loading'
    className: 'loading,'

  Loading
