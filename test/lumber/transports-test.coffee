###
transports-test.js: Tests to ensure core transports load properly

(c) 2012 Panther Development
MIT LICENCE
###
fs = require("fs")
path = require("path")
vows = require("vows")
assert = require("assert")
cov = require("../coverage")
trans = cov.require("../lib/lumber/transports")
vows.describe("Transports").addBatch("transports loader":
  topic: ->
    null

  "should have the correct exports": ->
    assert.isObject trans
    assert.isFunction trans.Console
    assert.isFunction trans.File
    assert.isFunction trans.Webservice
).export module
