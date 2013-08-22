define ['secondfunnel', 'marionette', 'backbone', 'jquery', 'router', 'controller'], (SecondFunnel, Marionette, Backbone, $, Router, Controller) ->
  app = new Marionette.Application()
  app.addInitializer(->
    SecondFunnel.router = new Router()
    SecondFunnel.controller = new Controller()
    if (!Backbone.history.start(pushState: true))
      SecondFunnel.router.trigger('404')
  )
  app.addRegions(
    header: "header"
    main: "#container"
    footer: "footer"
  )
  SecondFunnel.app = app
  app

