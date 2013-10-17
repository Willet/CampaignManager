define("app",
    ['marionette', 'jquery', 'underscore', 'entities', 'components/regions/reveal', 'exports'],
    function (Marionette, $, _, Entities, Reveal, exports) {
        var App, CurrentPage;
        App = window.App = new Marionette.Application();
        App.APP_ROOT = window.APP_ROOT;

        if (window.location.hostname === '127.0.0.1' ||
            window.location.hostname === 'localhost') {  // dev
            App.API_ROOT = window.location.origin + "/graph/v1";
        } else if (window.location.hostname.indexOf('-test') > 0) {  // test bucket
            App.API_ROOT = "http://secondfunnel-test.elasticbeanstalk.com/graph/v1";
        } else {  // assumed production bucket
            App.API_ROOT = "http://secondfunnel.elasticbeanstalk.com/graph/v1";
        }

        App.addRegions({
            modal: {
                selector: "#modal",
                regionType: Reveal.RevealDialog
            },
            layout: "#layout",
            header: "header",
            footer: "footer"
        });
        CurrentPage = Entities.Model.extend({});
        App.currentPage = new CurrentPage();
        App.addInitializer(function () {
            $(document).ajaxError(function (event, xhr) {
                if (xhr.status === 401) {
                    console.log("a 401 happened");
                    return App.redirectToLogin();
                }
            });

            return App.pageInfo = new Entities.Model({
                title: "Loading",
                page: ""
            });
        });
        $.ajaxSetup({
            beforeSend: function (request) {
                request.setRequestHeader('ApiKey', 'secretword');
                return request.withCredentials = true;
            }
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
            return window.location = "" + App.APP_ROOT + "?r=" + window.location.hash;
        };
        App.setTitle = function (title) {
            return App.pageInfo.set("title", title);
        };
        _.extend(exports, App);
        return App;
    });