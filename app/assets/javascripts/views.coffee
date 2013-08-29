define [
  "views/main",
  "views/products",
  "views/content",
  "views/campaigns",
  "views/stores"
], (Main, Products, Content, Campaigns, Stores) ->
  SecondFunnel.Views = {
    Main: Main
    Products: Products
    Content: Content
    Campaigns: Campaigns
    Stores: Stores
  }

