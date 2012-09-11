###
lumber-test.js: Tests to ensure lumber exports itself correctly

(c) 2012 Panther Development
MIT LICENCE
###
fs = require("fs")
path = require("path")
vows = require("vows")
assert = require("assert")
cov = require("./coverage")
lumber = cov.require("../lib/lumber")

#global export

#transports

#encoders

#utils

#core

#config

#levels functions, for default logger
#
#              Object.keys(lumber.defaults.levels).forEach(function(k) {
#              assert.isFunction(lumber[k]);
#              });
#            
vows.describe("Lumber").addBatch("lumber module":
  topic: ->
    null

  "should have the correct exports": ->
    assert.isObject lumber
    assert.isObject lumber.transports
    assert.isFunction lumber.transports.Console
    assert.isFunction lumber.transports.File
    assert.isFunction lumber.transports.Webservice
    assert.isObject lumber.encoders
    assert.isFunction lumber.encoders.Json
    assert.isFunction lumber.encoders.Xml
    assert.isFunction lumber.encoders.Text
    assert.isObject lumber.util
    assert.isFunction lumber.Logger
    assert.isFunction lumber.Transport
    assert.isFunction lumber.Encoder
    assert.isObject lumber.defaults
    assert.isObject lumber.defaults.levels
    assert.isObject lumber.defaults.colors

  should:
    topic: ->
      fs.readFile path.join(__dirname, "..", "package.json"), @callback

    "have the correct version": (err, data) ->
      assert.isNull err
      s = JSON.parse(data.toString())
      assert.equal lumber.version, s.version
).export module
