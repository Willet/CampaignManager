define ['secondfunnel', 'marionette', 'backbone', 'jquery', 'router', 'controller', 'views', 'regions'],
 (SecondFunnel, Marionette, Backbone, $, Router, Controller, Views, Regions) ->
  app = SecondFunnel.app = new Marionette.Application()
  app.addInitializer(->
    SecondFunnel.router = new Router()
    SecondFunnel.controller = new Controller()
    SecondFunnel.app.header.show(new Views.Main.Nav(model: new Backbone.Model(page: "none")))
    SecondFunnel.app.titlebar.show(new Views.Main.TitleBar(model: new Backbone.Model({title: "Loading..."})))
    if (!Backbone.history.start(pushState: true))
      SecondFunnel.router.trigger('404')
  )
  app.addRegions(
    modal: 
      selector: "#modal"
      regionType: Regions.RevealDialog
    header: "header"
    infobar: "#info-bar"
    titlebar: "#title-bar"
    main: "#container"
    footer: "footer"
  )
  app

