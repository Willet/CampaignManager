/* global define, describe, it, should, expect, before, beforeEach */
define(['app', 'dao/content', 'dao/pages'], function(App) {
    'use strict';
    var store = null;
    var content = null;
    var page = null;

    describe('Content', function () {
        this.timeout(5000); // set 5 second timeout on tests

        describe('PageContent', function () {
            before(function(done) {
                page = App.request('page:get', {'store_id': 1, 'page_id': 1});
                App.execute('when:fetched', page, done);
            });

            describe('Add/Remove Page Content', function () {
                before(function(done) {
                    // remove content from page if it is in page
                    content = App.request('page:content:get', page, 24);
                    App.execute('when:fetched', content, function() {
                        if(content.getPageTile()) {
                            var request = App.request('page:remove_content', page, content);
                            App.execute('when:fetched', request, done);
                        } else {
                            done();
                        }
                    });
                });

                it('add content to page', function(done) {
                    content = App.request('page:content:get', page, 24);
                    App.execute('when:fetched', content, function() {
                        expect(content.getPageTile()).to.not.exist;
                        expect(content.get('page-status')).to.equal(null)
                        var request = App.request('page:add_content', page, content);
                        request.complete(function() {
                            expect(content.getPageTile()).to.exist;
                            expect(content.get('page-status')).to.equal('added')
                            done();
                        });
                    });
                });

            });

            describe('All Content', function () {
                it('has all content', function(done) {
                    var content = App.request('page:content:all', page);
                    App.execute('when:fetched', content, function() {
                        expect(content.size()).to.equal(4);
                        done();
                    });
                });
            });
        });
    });
});
