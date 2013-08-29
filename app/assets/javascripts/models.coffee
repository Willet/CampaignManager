define [
  "backbone",
  "backbonerelational",
  "models/products",
  "models/content",
  "models/pages",
  "models/stores"
], (Backbone, BackboneRelation, Products, Content, Pages, Stores) ->
  Backbone.Relational.store.addModelScope(window)
  window.Models = {
    Products: Products
    Content: Content
    Pages: Pages
    Store: Stores
  }

