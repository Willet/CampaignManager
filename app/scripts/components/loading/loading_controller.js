define(['exports', 'app', 'marionette', 'underscore'], function(Loading, App, Marionette, _) {
    'use strict';

    Loading.LoadingController = _.extends(App.Controllers.Base, {

        initialize: function (options) {
            var view, config;
            view = options.view;
            config = options.config;

            if (_.isBoolean(config)) {
                config = {};
            }

            _.defaults(config, {
                entities: this.getEntities(),
                debug: false
            });

            var loadingView = this.getLoadingView();
            this.show(loadingView);
            this.showRealView(view, loadingView, options);
        },

        showRealView: function (realView, loadingView, config) {
            var _this = this;
            App.execute('when:fetched', config.entities, function() {
                if (_this.region.currentView !== loadingView) {
                    return realView.close();
                }
                if (!config.debug) {
                    return _this.show(realView);
                }
            });
        },

        getEntities: function (view) {
            return _.chain(view).pick('model', 'collection').toArray().compact().value();
        },

        getLoadingView: function() {
            new Loading.LoadingView();
        }

    });

    App.commands.setHandler('show:loading', function (view, options) {
        new Loading.LoadingController({
            view: view,
            region: options.region,
            config: options.loading
        });
    });

});