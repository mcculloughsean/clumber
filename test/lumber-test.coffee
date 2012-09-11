###
lumber-test.js: Tests to ensure lumber exports itself correctly

(c) 2012 Panther Development
MIT LICENCE
###
fs = require("fs")
path = require("path")
mocha = require("mocha")
assert = require("chai").assert
lumber = require("../lib/lumber")

describe "Lumber", () ->

  it "should export subobjects", ->
    assert.isObject lumber
    assert.isObject lumber.transports
    assert.isObject lumber.encoders
    assert.isObject lumber.util

  it "should export defaults", ->
    assert.isObject lumber.defaults
    assert.isObject lumber.defaults.levels
    assert.isObject lumber.defaults.colors

  it "should export core transports", ->
    assert.isFunction lumber.transports.Console
    assert.isFunction lumber.transports.File
    assert.isFunction lumber.transports.Webservice

  it "should export core encoders", ->
    assert.isFunction lumber.encoders.Json
    assert.isFunction lumber.encoders.Text

  it "should export core", ->
    assert.isFunction lumber.Logger
    assert.isFunction lumber.Transport
    assert.isFunction lumber.Encoder

  describe "npm package", ()->

    it "has the correct version", (done) ->
      fs.readFile path.join(__dirname, "..", "package.json"), (err, data) ->
        return done(err) if err?
        s = JSON.parse(data.toString())
        assert.equal lumber.version, s.version
        done()
