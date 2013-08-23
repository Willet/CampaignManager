define ["marionette", "models/campaigns"], (Marionette, Campaigns) ->

  class Index extends Marionette.Layout

    template: "campaigns_index"

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  class Show extends Marionette.Layout

    template: "campaigns_show"

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  # declare exports
  return {
    Index: Index
    Show: Show
  }


