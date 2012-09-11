###
file-test.js: Tests the file transport

(c) 2012 Panther Development
MIT LICENSE
###
fs = require("fs")
path = require("path")
vows = require("vows")
assert = require("assert")
cov = require("../../coverage")
lumber = cov.require("../lib/lumber")
vows.describe("File").addBatch("file transport":
  topic: ->
    new lumber.transports.File()

  has:
    "the correct defaults": (trans) ->
      assert.instanceOf trans.encoder, lumber.encoders.Json
      assert.isFunction trans.encoder.encode
      assert.equal trans.level, "info"
      assert.equal trans.filename, path.resolve("app.log")

    "the correct functions": (trans) ->
      assert.isFunction trans.log

  should:
    topic: (trans) ->
      try
        fs.unlinkSync path.resolve("app.log")
      logger = new lumber.Logger(transports: [trans])
      logger.log "info", "A message"
      logger.on "log", @callback

    "create the proper file": (err, msg, level, name, filename) ->
      f = undefined
      try
        f = fs.statSync(path.resolve("app.log"))
      assert.isTrue not err
      assert.isTrue !!f

    "pass the correct params": (err, msg, level, name, filename) ->
      assert.isTrue not err
      assert.equal level, "info"
      assert.equal name, "file"
      assert.equal filename, path.resolve("app.log")

    "write properly enocoded data": (err, msg, level, name, filename) ->
      assert.isTrue not err
      assert.equal msg.trim(), fs.readFileSync(path.resolve("app.log"), "utf8").trim()

    teardown: (err) ->
      try
        fs.unlinkSync path.resolve("app.log")
).export module
