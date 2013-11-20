define(['app', './app', './views', 'marionette'],
    function (App, PageManager, Views, Marionette) {
        'use strict';

        PageManager.Controller = Marionette.Controller.extend({

            pagesIndex: function () {
                new PageManager.List.Controller({region: this.region});
            },

            pagesName: function () {
                new PageManager.Name.Controller({region: this.region});
            },

            pagesLayout: function () {
                new PageManager.Layout.Controller({region: this.region});
            },

            pagesProducts: function () {
                new PageManager.Products.Controller({region: this.region});
            },

            pagesContent: function () {
                new PageManager.Content.Controller({region: this.region});
            },

            pagesView: function () {
                new PageManager.Preview.Controller({region: this.region});
            },

            publishView: function () {
                new PageManager.Publish.Controller({region: this.region});
            }
        });

        return PageManager;
    });
