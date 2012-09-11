###
file-rotation-test.js: Tests the file transport rotation

(c) 2012 Panther Development
MIT LICENSE
###
fs = require("fs")
path = require("path")
vows = require("vows")
assert = require("assert")
cov = require("../../coverage")
lumber = cov.require("../lib/lumber")
logFile = path.resolve("rotate.log")
vows.describe("FileRotate").addBatch("file transport with rotate":
  topic: ->
    new lumber.transports.File(
      filename: logFile
      maxlength: 100
    )

  should:
    topic: (trans) ->
      try
        fs.unlinkSync logFile
      logger = new lumber.Logger(transports: [trans])
      trans.on "rotate", ->
        console.log "ROTATE"

      logger.log "info", "A message"
      logger.log "info", "A message"
      logger.on "log", @callback

    "create the proper file": (err, msg, level, name, filename) ->
      f = undefined
      try
        f = fs.statSync(logFile)
      assert.isTrue not err
      assert.isTrue !!f

    "pass the correct params": (err, msg, level, name, filename) ->
      assert.isTrue not err
      assert.equal level, "info"
      assert.equal name, "file"
      assert.equal filename, logFile

    "write properly enocoded data": (err, msg, level, name, filename) ->
      assert.isTrue not err
      assert.equal msg.trim(), fs.readFileSync(logFile, "utf8").trim()

    teardown: (err) ->
      try
        fs.unlinkSync logFile
).export module
