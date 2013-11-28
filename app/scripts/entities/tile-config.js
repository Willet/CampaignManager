define([
    'app', 'entities/base', 'entities/products', 'backbone'
], function (App, Base, Entities, Backbone) {
    'use strict';
    Entities = Entities || {};

    Entities.TileConfig = Base.Model.extend({
        relations: [
            {
                type: Backbone.Many,
                key: 'products',
                relatedModel: Entities.Product
            },
            {
                type: Backbone.Many,
                key: 'content',
                relatedModel: Entities.Content
            }
        ]
    });

    Entities.TileConfigCollection = Base.PageableCollection.extend({
        model: Entities.TileConfig
    });

    return Entities;
});
