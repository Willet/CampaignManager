define [
  "backbone",
  "backbonerelational",
  "models/products",
  "models/content",
  "models/campaigns",
  "models/stores"
], (Backbone, BackboneRelation, Products, Content, Campaigns, Stores) ->
  Backbone.Relational.store.addModelScope(window)
  window.Models = {
    Products: Products
    Content: Content
    Campaigns: Campaigns
    Store: Stores
  }

