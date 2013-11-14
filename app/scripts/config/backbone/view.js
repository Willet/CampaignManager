// Patch change from Backbone 1.0.0 to 1.1.0
require(['backbone'], function(Backbone) {
    'use strict';
    var View = Backbone.View;
    Backbone.View = View.extend({
        constructor: function (options) {
            this.options = options;
            View.apply(this, arguments);
        }
    });
    return Backbone;
});