define('app',
    ['marionette', 'jquery', 'underscore', 'entities', 'components/regions/reveal', 'exports'],
    function (Marionette, $, _, Entities, Reveal, exports) {
        'use strict';
        var App = window.App = new Marionette.Application();
        App.APP_ROOT = window.APP_ROOT;
        App.ENVIRONMENT = '';
        App.Views = {};
        App.Controllers = {};

        App.rootRoute = 'login';

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
            App.API_ROOT = 'http://test.secondfunnel.com/graph/v1';
            App.ENVIRONMENT = 'TEST';
        } else {  // assumed production bucket
            App.API_ROOT = 'http://secondfunnel.com/graph/v1';
            App.ENVIRONMENT = 'PRODUCTION';

            // production db isn't ready.
            App.API_ROOT = 'http://test.secondfunnel.com/graph/v1';
        }

        App.addInitializer(function () {
            $(document).ajaxError(function (event, xhr) {
                if (xhr.status === 401) {
                    console.log('a 401 happened');
                    return App.redirectToLogin();
                }
            });

            App.pageInfo = new Entities.Model({
                title: 'Loading',
                page: ''
            });
        });
        $.ajaxSetup({
            // there are records online that indicate this works, but...
            beforeSend: function (request) {
                request.setRequestHeader('ApiKey', 'secretword');
                request.withCredentials = true;
                request.xhrFields = {
                    withCredentials: true
                };
                return request;
            },
            // ... it took these to work, at least for chrome.
            withCredentials: true,
            xhrFields: {
                withCredentials: true
            }
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
        App.setTitle = function (title) {
            return App.pageInfo.set('title', title);
        };
        _.extend(exports, App);
        return App;
    });
