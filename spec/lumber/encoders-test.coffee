###
encoders-test.js: Tests to ensure core encoders load properly

(c) 2012 Panther Development
MIT LICENCE
###
fs = require "fs"
path = require "path"
mocha = require "mocha"
assert = require("chai").assert
encoders = require "../../src/lumber/encoders"

describe "Encoders", ->

  it "should have the correct exports", ->
    assert.isObject encoders
    assert.isFunction encoders.Text
    assert.isFunction encoders.Json
