define([
    'app', 'dao/base', 'entities'
], function (App, Base, Entities) {
    'use strict';

    var API = {
        getPageTiles: function(storeId, pageId, params) {
            var tileconfigs = new Entities.TileConfigCollection();
            tileconfigs.pageId = pageId;
            tileconfigs.url = App.API_ROOT + '/store/' + storeId + '/page/' + pageId + '/tile-config';
            tileconfigs.setFilter(params);
            return tileconfigs;
        },
        getFromConfig: function(config) {
            var id, field, template;
            config = config || {};

            switch(config.template) {
            case 'product':
                field = 'product-ids';
                break;
            default:
                field = 'content-ids';
            }

            id = config.id || -1;
            template = config.template || 'image';

            return {
                'id': id,
                'field': field,
                'template': template
            };
        },

        prioritizeTile: function(page, tileconfig) {
            var tileconfigUrl = App.API_ROOT + '/store/' + page.get('store-id') + '/page/' + page.get('id') + '/tile-config/' + tileconfig.get('id');
            tileconfig.save({}, { method: 'POST', url: tileconfigUrl + '/prioritize' });
        },

        deprioritizeTile: function(page, tileconfig) {
            var tileconfigUrl = App.API_ROOT + '/store/' + page.get('store-id') + '/page/' + page.get('id') + '/tile-config/' + tileconfig.get('id');
            tileconfig.save({}, { method: 'POST', url: tileconfigUrl + '/deprioritize' });
        }

    };

    App.reqres.setHandler('tileconfig:prioritize', function(page, tileconfig) {
        tileconfig.set('prioritized', true);
        API.prioritizeTile(page, tileconfig);
    });

    App.reqres.setHandler('tileconfig:deprioritize', function(page, tileconfig) {
        tileconfig.set('prioritized', false);
        API.deprioritizeTile(page, tileconfig);
    });

    App.reqres.setHandler('page:tileconfig', function(page, params) {
        return API.getPageTiles(page.get('store-id'), page.get('id'), params);
    });

});
