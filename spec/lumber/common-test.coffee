###
common-test.js: Tests to ensure commong functions work properly

(c) 2012 Panther Development
MIT LICENCE
###
fs = require "fs"
path = require "path"
mocha = require "mocha"
assert = require("chai").assert
common = require "../../src/lumber/common"

describe "common module", ->

  it "should have the correct exports",  ->
    assert.isFunction common.titleCase
    assert.isFunction common.generateGuid
    assert.isFunction common.pad
    assert.isFunction common.colorize
    assert.isFunction common.prepareArgs

describe "when using titleCase", ->
  it "single words should uppercase", ->
    assert.equal common.titleCase("hey"), "Hey"
    assert.equal common.titleCase("down"), "Down"

  it "multiple words should uppercase",  ->
    assert.equal common.titleCase("hey there"), "Hey There"
    assert.equal common.titleCase("Hey ho, let's Go!\nlawl no, sir!"), "Hey Ho, Let's Go!\nLawl No, Sir!"

describe "when generating a guid", ->

  it "should match the guid pattern", ->
    regex = /^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$/
    assert.match common.generateGuid(), regex
    assert.match common.generateGuid(), regex
    assert.match common.generateGuid(), regex
    assert.match common.generateGuid(), regex
    assert.match common.generateGuid(), regex
    assert.match common.generateGuid(), regex

describe "when padding a string", ->
  it "should be the right length", ->
    assert.lengthOf common.pad("str", " ", 10), 10
    assert.lengthOf common.pad("19", "0", 3), 3
    assert.lengthOf common.pad("dots", ".", 25), 25

  it "should be the right pad char", ->
    assert.equal common.pad("str", " ", 10), "       str"
    assert.equal common.pad("19", "0", 3), "019"
    assert.equal common.pad("dots", ".", 25), ".....................dots"

describe "when colorizing a string", ->

  it "should be the right color", ->
    colors =
      info: "cyan"
      error: "red"
      warn: "yellow"
      verbose: "grey"
    assert.equal common.colorize("str", "info", colors), "\u001b[36mstr\u001b[39m"
    assert.equal common.colorize("str", "error", colors), "\u001b[31mstr\u001b[39m"
    assert.equal common.colorize("str", "warn", colors), "\u001b[33mstr\u001b[39m"
    assert.equal common.colorize("str", "verbose", colors), "\u001b[90mstr\u001b[39m"
