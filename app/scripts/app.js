define('app',
    ['marionette', 'jquery', 'underscore', 'entities', 'components/regions/reveal', 'exports'],
    function (Marionette, $, _, Entities, Reveal, exports) {
        'use strict';
        var App = window.App = new Marionette.Application();
        App.APP_ROOT = window.APP_ROOT;
        App.ENVIRONMENT = '';
        App.Views = {};
        App.Controllers = {};

        App.rootRoute = '';

        App.addRegions({
            modal: {
                selector: '#modal',
                regionType: Reveal.RevealDialog
            },
            layout: '#layout',
            header: 'header',
            footer: 'footer'
        });

        if (window.location.hostname === '127.0.0.1' ||
            window.location.hostname === 'localhost') {  // dev
            App.API_ROOT = window.location.origin + '/graph/v1';
            App.ENVIRONMENT = 'DEV';
        } else if (window.location.hostname.indexOf('-test') > 0) {  // test bucket
            App.API_ROOT = 'http://tng-test.secondfunnel.com/graph/v1';
            App.ENVIRONMENT = 'TEST';
        } else {  // assumed production bucket
            App.API_ROOT = 'http://tng-master.secondfunnel.com/graph/v1';
            App.ENVIRONMENT = 'PRODUCTION';
        }

        App.addInitializer(function () {
            $(document).ajaxError(function (event, xhr) {
                if (xhr.status === 401) {
                    console.log('a 401 happened');
                    return App.redirectToLogin();
                }
            });
        });

        App.on('initialize:after', function () {
            this.startHistory();
            if (!this.getCurrentRoute()) {
                return this.navigate(App.rootRoute, { trigger: true });
            }
        });

        App.commands.setHandler('when:fetched', function (entities, callback) {
            var xhrs;
            xhrs = _.chain([entities]).flatten().pluck('_fetch').value();
            return $.when.apply($, xhrs).done(function () {
                return callback();
            });
        });

        App.reqres.setHandler('default:region', function() {
            return App.layout;
        });

        App.commands.setHandler('register:instance', function (instance, id) {
            App.register(instance, id);
        });

        App.commands.setHandler('unregister:instance', function (instance, id) {
            App.unregister(instance, id);
        });

        App.redirectToLogin = function () {
            App.navigate('', { trigger: true });
        };

        // because exports is required (otherwise too many cyclic dependencies)
        // may be able to REVERSE the direction, and make everything else export.
        // but it is a fair bit of work at the current point in time
        _.extend(exports, App);

        return App;
    });
