define([
    'entities/base',
    'entities/products',
    'entities/content',
    'entities/pages',
    'entities/stores',
    'entities/categories',
    'entities/scrape',
    'entities/tile-config',
    'entities/user',
    'underscore',
    'exports'
], function (Base, Products, Content, Pages, Stores, Categories, Scrape, TileConfig, User, _, exports) {
    'use strict';
    window.Entities = _.extend(exports, Base, Products, Content, Pages, Stores, Categories, Scrape, TileConfig, User);
    return window.Entities;
});
