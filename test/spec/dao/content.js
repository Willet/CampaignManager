/* global define, describe, it, should, expect, before */
define(['app'], function(App) {
    'use strict';

    describe('Content', function () {
        describe('List', function () {
            var store = null;
            var content = null;
            before(function(done) {
                store = App.request('store:get', {'store_id':38});
                App.execute('when:fetched', store, function() {
                    content = App.request('store:content', store);
                    App.execute('when:fetched', content, done);
                });
            });

            it('100 results returned', function () {
                expect(content.size()).to.equal(100);
            });
        });
    });
});
