/*global define*/
define("app",
    ['marionette', 'jquery', 'underscore', 'entities', 'components/regions/reveal', 'exports'],
    function (Marionette, $, _, Entities, Reveal, exports) {
        "use strict";
        var App;
        App = window.App = new Marionette.Application();
        App.APP_ROOT = window.APP_ROOT;
        App.API_ROOT = App.APP_ROOT + "api";
        App.addRegions({
            modal: {
                selector: "#modal",
                regionType: Reveal.RevealDialog
            },
            nav: "header",
            infobar: "#info-bar",
            titlebar: "#title-bar",
            main: "#container",
            footer: "footer"
        });
        App.addInitializer(function () {
            $(document).ajaxError(function (event, xhr) {
                if (xhr.status === 401) {
                    return App.redirectToLogin();
                }
            });
            return App.pageInfo = new Entities.Model({
                title: "Loading",
                page: ""
            });
        });
        App.on("initialize:after", function (options) {
            this.startHistory();
            if (!this.getCurrentRoute()) {
                return this.navigate(App.APP_ROOT, {
                    trigger: true
                });
            }
        });
        App.commands.setHandler("when:fetched", function (entities, callback) {
            var xhrs;
            xhrs = _.chain([entities]).flatten().pluck("_fetch").value();
            return $.when.apply($, xhrs).done(function () {
                return callback();
            });
        });
        App.redirectToLogin = function () {
            return window.location = "" + App.APP_ROOT + "login?r=" + window.location.hash;
        };
        App.setTitle = function (title) {
            return App.pageInfo.set("title", title);
        };
        _.extend(exports, App);
        return App;
    });