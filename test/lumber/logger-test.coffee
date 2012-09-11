###
logger-test.js: Tests to ensure logger class functions properly

(c) 2012 Panther Development
MIT LICENCE
###
fs = require "fs"
path = require "path"
mocha = require "mocha"
assert = require("chai").assert
lumber = require "../../lib/lumber"

logger = undefined
describe "Logger", ->
  beforeEach () ->
    logger = new lumber.Logger()

    it "has the correct deaults",  ->
      assert.isObject logger.levels
      assert.deepEqual logger.levels, lumber.defaults.levels
      assert.deepEqual logger.colors, lumber.defaults.colors

    it "has the correct functions",  ->
      assert.isFunction logger.log
      Object.keys(logger.levels).forEach (key) ->
        assert.isFunction logger[key]

trans = undefined
describe "Logger", ->
  beforeEach ->
    trans =
      level: "info"
      log: ->

      encoder: {}

    logger = new lumber.Logger(transports: [trans])

  it "does not call silent log", ->
    trans.log = ->
      assert.isTrue false

    logger.log "silent", "message"
    logger.silent "message"

  it "calls error log", ->
    trans.log = ->
      assert.isTrue true

    logger.log "error", "message"
    logger.error "message"

  it "calls warn log", ->
    trans.log = ->
      assert.isTrue true

    logger.log "warn", "message"
    logger.warn "message"

  it "calls info log", ->
    trans.log = ->
      assert.isTrue true

    logger.log "info", "message"
    logger.info "message"

  it "not call verbose log", ->
    trans.log = ->
      assert.isTrue false

    logger.log "verbose", "message"
    logger.verbose "message"

  it "not call debug log", ->
    trans.log = ->
      assert.isTrue false

    logger.log "debug", "message"
    logger.debug "message"

  it "not call silly log", ->
    trans.log = ->
      assert.isTrue false

    logger.log "silly", "message"
    logger.silly "message"
