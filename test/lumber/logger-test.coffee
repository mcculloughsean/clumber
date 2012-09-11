###
logger-test.js: Tests to ensure logger class functions properly

(c) 2012 Panther Development
MIT LICENCE
###
fs = require("fs")
path = require("path")
vows = require("vows")
assert = require("assert")
cov = require("../coverage")
lumber = cov.require("../lib/lumber")

#make test fail if called

#make test pass if called

#make test pass if called

#make test pass if called

#make test fail if called

#make test fail if called

#make test fail if called
vows.describe("Logger").addBatch("logger module":
  topic: ->
    new lumber.Logger()

  has:
    "the correct deaults": (logger) ->
      assert.isObject logger.levels
      assert.deepEqual logger.levels, lumber.defaults.levels
      assert.deepEqual logger.colors, lumber.defaults.colors

    "the correct functions": (logger) ->
      assert.isFunction logger.log
      Object.keys(logger.levels).forEach (key) ->
        assert.isFunction logger[key]


  should:
    topic: ->
      trans =
        level: "info"
        log: ->

        encoder: {}

      logger = new lumber.Logger(transports: [trans])
      trans: trans
      logger: logger

    "not call silent log": (o) ->
      o.trans.log = ->
        assert.isTrue false

      o.logger.log "silent", "message"
      o.logger.silent "message"

    "call error log": (o) ->
      o.trans.log = ->
        assert.isTrue true

      o.logger.log "error", "message"
      o.logger.error "message"

    "call warn log": (o) ->
      o.trans.log = ->
        assert.isTrue true

      o.logger.log "warn", "message"
      o.logger.warn "message"

    "call info log": (o) ->
      o.trans.log = ->
        assert.isTrue true

      o.logger.log "info", "message"
      o.logger.info "message"

    "not call verbose log": (o) ->
      o.trans.log = ->
        assert.isTrue false

      o.logger.log "verbose", "message"
      o.logger.verbose "message"

    "not call debug log": (o) ->
      o.trans.log = ->
        assert.isTrue false

      o.logger.log "debug", "message"
      o.logger.debug "message"

    "not call silly log": (o) ->
      o.trans.log = ->
        assert.isTrue false

      o.logger.log "silly", "message"
      o.logger.silly "message"
).export module
