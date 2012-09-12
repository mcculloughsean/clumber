###
console-test.js: Tests the console transport

(c) 2012 Panther Development
MIT LICENSE
###
fs = require "fs"
path = require "path"
mocha = require "mocha"
assert = require("chai").assert
lumber = require "../../../src/lumber"

con = undefined
describe "Console", ->
  beforeEach ->
    con = new lumber.transports.Console()

  it "has the correct defaults", ->
    assert.instanceOf con.encoder, lumber.encoders.Text
    assert.isFunction con.encoder.encode
    assert.equal con.level, "info"

  it "has the correct functions", ->
    assert.isFunction con.log
