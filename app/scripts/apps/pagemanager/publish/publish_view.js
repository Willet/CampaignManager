define(['app', '../views', 'backbone', 'backbone.stickit'],
    function (App, Views) {
        'use strict';
        Views.PublishPage = App.Views.Layout.extend({
            'regions': {
                'fail': '.fail'
            },
            template: 'page/publish',
            initialize: function (opts) {
                this.store = opts.store;
            },
            serializeData: function () {
                return {
                    page: this.model.toJSON(),
                    url: this.store.get('public-base-url'),
                    store: this.store.toJSON()
                };
            },
            events: {
                'click .js-next': 'publish'
            },
            publish: function() {
                this.$('.publish.button').text('Publishing...');
                this.$(this.fail.el).hide();
                this.trigger('publish');
            },
            onRender: function () {
                this.stickit();
                this.$('.fail').hide();

                return this.$('.steps .publish').addClass('active');
            }
        });

        return Views;
    });
