define ['secondfunnel', 'marionette', 'backbone', 'jquery', 'router', 'controller', 'views'], (SecondFunnel, Marionette, Backbone, $, Router, Controller, Views) ->
  app = SecondFunnel.app = new Marionette.Application()
  app.addInitializer(->
    SecondFunnel.router = new Router()
    SecondFunnel.controller = new Controller()
    if (!Backbone.history.start(pushState: true))
      SecondFunnel.router.trigger('404')
    SecondFunnel.app.header.show(new Views.Main.Nav())
    SecondFunnel.app.titlebar.show(new Views.Main.TitleBar(model: new Backbone.Model({title: "Loading..."})))
  )
  app.addRegions(
    header: "header"
    infobar: "#info-bar"
    titlebar: "#title-bar"
    main: "#container"
    footer: "footer"
  )
  app

