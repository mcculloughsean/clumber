fs = require "fs"
path = require "path"
mocha = require "mocha"
assert = require("chai").assert
dateFormat = require "dateformat"
tk = require 'timekeeper'
lumber = require "../../../src/lumber"

trans = logger = undefined
mainLogFilePath = path.resolve 'app.log'
describe "Process Transport", ->
  before ->
    trans = new lumber.transports.Process
      command: [ __dirname + "/../../piper", mainLogFilePath ]

  it "has the correct defaults", ->
    assert.instanceOf trans.encoder, lumber.encoders.Json
    assert.isFunction trans.encoder.encode
    assert.equal trans.level, "info"

  it "the correct functions", ->
    assert.isFunction trans.log

  describe "functionally", ->
    logResponse = undefined
    before (done) ->
      logger = new lumber.Logger(transports: [trans])
      logger.on "log", (err, msg, level, name, filename) ->
        return unless msg?
        logResponse = { msg, level, name }
        setTimeout () ->
          done err
        , 1000
      logger.log "info", "A message"

    after ->
      try
        fs.unlinkSync mainLogFilePath

    it "creates the proper file", () ->
      f = undefined
      try
        f = fs.statSync mainLogFilePath
      assert.isTrue !!f

    it "passes the correct params", () ->
      assert.equal logResponse.level, "info"
      assert.equal logResponse.name, "process"

    it "writes properly enocoded data", () ->
      assert.equal logResponse.msg.trim(), fs.readFileSync(mainLogFilePath, "utf8").trim()


