###
text-test.js: Tests the text encoder

(c) 2012 Panther Development
MIT LICENSE
###
fs = require "fs"
path = require "path"
mocha = require "mocha"
assert = require("chai").assert
lumber = require "../../../lib/lumber"
inspect = require("eyes").inspector(stream: null)

enc = undefined
describe "Text", ->
  beforeEach ->
    enc = new lumber.encoders.Text()

  it "has the correct defaults", ->
    assert.isTrue enc.colorize
    assert.isFalse enc.timestamp
    assert.equal enc.headFormat, "%l: "
    assert.equal enc.dateFormat, "isoDateTime"
    assert.equal enc.contentType, "text/plain"
    assert.isFunction enc.inspect

  it "has the correct functions", ->
    assert.isFunction enc.encode

  describe "enocde", ->
    it "works without timestamp, or meta", ->
      enc.timestamp = false
      assert.equal enc.encode("info", "The Message"), "info: The Message"
      assert.equal enc.encode("warn", "The Message"), "warn: The Message"
      assert.equal enc.encode("error", "The Message"), "error: The Message"

    it "works with timestamp, without meta", ->
      enc.timestamp = true
      assert.match enc.encode("info", "The Message"), /info: \([\d\-]+T[\d:]+\) The Message/
      assert.match enc.encode("warn", "The Message"), /warn: \([\d\-]+T[\d:]+\) The Message/
      assert.match enc.encode("error", "The Message"), /error: \([\d\-]+T[\d:]+\) The Message/

    it "works without timestamp, with meta", ->
      enc.timestamp = false
      assert.equal enc.encode("info", "The Message",
        meta: "data"
      ), "info: The Message\n\u001b[36m" + inspect(meta: "data")
      assert.equal enc.encode("warn", "The Message",
        meta: "data"
      ), "warn: The Message\n\u001b[36m" + inspect(meta: "data")
      assert.equal enc.encode("error", "The Message",
        meta: "data"
      ), "error: The Message\n\u001b[36m" + inspect(meta: "data")

    it "works with timestamp, and meta", ->
      enc.timestamp = true
      assert.match enc.encode("info", "The Message",
        meta: "data"
      ), (/^info: \([\d\-]+T[\d:]+\) The Message\n.+\{ .+ \}.+$/)
      assert.match enc.encode("warn", "The Message",
        meta: "data"
      ), (/^warn: \([\d\-]+T[\d:]+\) The Message\n.+\{ .+ \}.+$/)
      assert.match enc.encode("error", "The Message",
        meta: "data"
      ), (/^error: \([\d\-]+T[\d:]+\) The Message\n.+\{ .+ \}.+$/)
