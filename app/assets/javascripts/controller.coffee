define [
    "secondfunnel",
    "marionette",
    "views/main",
    "views/products"
  ], (SecondFunnel, Marionette, MainView, ProductsView) ->
    # Controller
    class Controller extends Marionette.Controller

      initialize: (opts) ->

      root: (opts) ->
        SecondFunnel.app.main.show(new MainView())

      productIndex: (opts) ->
        SecondFunnel.app.main.show(new ProductsView())

      productShow: (opts) ->
        console.log opts

