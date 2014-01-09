/* global define */
define([
    // List of all tests to run
    'chai',
    'spec/test.js',
    'spec/dao/content.js'
], function (chai) {
    'use strict';

    // Setup Test Environment
    window.console = window.console || function() {};
    window.notrack = true;
    window.chai = chai;
    window.expect = chai.expect;
    window.asset = chai.asset;

    // Run Tests
    window.mocha.run();
});
