define([
    'app', 'dao/base', 'entities'
], function (App, Base, Entities) {
    'use strict';

    var API = {
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
        addTileConfig: function(pageId, config) {
            var tileConfigCollection,
                obj = {},
                template = 'template';

            config = this.getFromConfig(config);

            obj[template] = config[template];
            obj[config.field] = [config.id];

            tileConfigCollection = new Entities.TileConfigCollection();
            tileConfigCollection.url = App.API_ROOT + '/page/' + pageId + '/tile-config';
            tileConfigCollection.create(obj);
            //tileConfig.save();
        },

        deleteTileConfig: function(pageId, config) {
            var tileConfigCollection, obj = {};

            config = this.getFromConfig(config);

            obj[config.field] = config.id;

            tileConfigCollection = new Entities.TileConfigCollection();
            tileConfigCollection.url = App.API_ROOT + '/page/' + pageId + '/tile-config';

            tileConfigCollection.fetch({
                data: obj
            }).done(function() {
                //http://stackoverflow.com/questions/10858935/cleanest-way-to-destroy-every-model-in-a-collection-in-backbone
                var i;
                for (i = tileConfigCollection.length -1; i >= 0; i--) {
                    tileConfigCollection.at(i).destroy();
                }
            });
        },

        prioritizeTile: function(page, tileconfig) {
            tileconfig.sync('deprioritize', tileconfig, {
                method: 'POST',
                url: tileconfig.url() + '/deprioritize',
                data: {},
                success: function(json) {
                    tileconfig.set(json);
                }
            });
        },

        deprioritizeTile: function(page, tileconfig) {
            tileconfig.sync('prioritize', tileconfig, {
                method: 'POST',
                url: tileconfig.url() + '/prioritize',
                data: {},
                success: function(json) {
                    tileconfig.set(json);
                }
            });
        }

    };

    App.reqres.setHandler('tileconfig:approve', function(pageId, config) {
        API.addTileConfig(pageId, config);
    });

    App.reqres.setHandler('tileconfig:reject', function(pageId, config) {
        API.deleteTileConfig(pageId, config);
    });

    App.reqres.setHandler('tileconfig:prioritize', function(page, tileconfig) {
        API.prioritizeTile(page, tileconfig);
    });

    App.reqres.setHandler('tileconfig:deprioritize', function(page, tileconfig) {
        API.deprioritizeTile(page, tileconfig);
    });

//    var API = {
//        login: function (username, password) {
//            var user = new Entities.User();
//            user.url = App.API_ROOT + '/user'; //
//            user.login(username, password);
//            return user;
//        },
//        logout: function () {
//
//        }
//    };
//
//    App.reqres.setHandler('user:login', function (username, password) {
//        var user = API.login(username, password);
//        App.user = user;
//    });
});
