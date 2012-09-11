###
transports-test.js: Tests to ensure core transports load properly

(c) 2012 Panther Development
MIT LICENCE
###
fs = require "fs"
path = require "path"
mocha = require "mocha"
assert = require("chai").assert
trans = require "../../lib/lumber/transports"

describe "Transports", ->
  it "should have the correct exports", ->
    assert.isObject trans
    assert.isFunction trans.Console
    assert.isFunction trans.File
    assert.isFunction trans.Webservice
