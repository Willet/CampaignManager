# Setup rendering to use JST given the template name
Backbone.Marionette.Renderer.render = (template, data) -> return JST[template](data)

this.SecondFunnel =
  Views: {}

# Views
class SecondFunnel.Views.MainIndex extends Backbone.Marionette.ItemView

  template: "main_index"

  initialize: (opts) ->

  onRender: (opts) ->

  onShow: (opts) ->

class SecondFunnel.Views.ProductIndex extends Backbone.Marionette.ItemView

  template: "products_index"

  initialize: (opts) ->

  onRender: (opts) ->

  onShow: (opts) ->

# Controller
class SecondFunnel.Controller extends Backbone.Marionette.Controller

  initialize: (opts) ->

  root: (opts) ->
    window.SecondFunnelApp.main.show(new SecondFunnel.Views.MainIndex())

  productIndex: (opts) ->
    window.SecondFunnelApp.main.show(new SecondFunnel.Views.ProductIndex())

  productShow: (opts) ->
    console.log opts

# Routing
class SecondFunnel.Router extends Backbone.Marionette.AppRouter
  controller: new SecondFunnel.Controller()

  appRoutes:
    "": "root"
    "products": "productIndex"
    "products/:id": "productShow"

  # standard not controller routes (call function in this router)
  routes: {}

@SecondFunnelApp = new Backbone.Marionette.Application()
@SecondFunnelApp.addInitializer(->
  router = new SecondFunnel.Router()
  Backbone.history.start(pushState: true)
)
@SecondFunnelApp.addRegions(
  main: "#container"
)
