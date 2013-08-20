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
  window.SecondFunnel.router = new SecondFunnel.Router()
  if (!Backbone.history.start(pushState: true))
    window.SecondFunnel.router.trigger('404')
)
@SecondFunnelApp.addRegions(
  main: "#container"
)

# Globally capture clicks. If they are internal and not in the pass
# through list, route them through Backbone's navigate method.
$(document).on "click", "a[href^='/']", (event) ->

  href = $(event.currentTarget).attr('href')

  # chain 'or's for other black list routes
  passThrough = href.indexOf('sign_out') >= 0

  # Allow shift+click for new tabs, etc.
  if !passThrough && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey
    event.preventDefault()

    # Remove leading slashes and hash bangs (backward compatablility)
    url = href.replace(/^\//,'').replace('\#\!\/','')

    # Instruct Backbone to trigger routing events
    window.SecondFunnel.router.navigate url, { trigger: true }

    return false

