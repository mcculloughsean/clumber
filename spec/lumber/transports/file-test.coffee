###
file-test.js: Tests the file transport

(c) 2012 Panther Development
MIT LICENSE
###
fs = require "fs"
path = require "path"
mocha = require "mocha"
assert = require("chai").assert
dateFormat = require "dateformat"
tk = require 'timekeeper'
lumber = require "../../../src/lumber"

trans = undefined
describe "File", ->
  beforeEach ->
    trans = new lumber.transports.File()

  it "has the correct defaults", ->
    assert.instanceOf trans.encoder, lumber.encoders.Json
    assert.isFunction trans.encoder.encode
    assert.equal trans.level, "info"
    assert.equal trans.filename, path.resolve "app.log"

  it "the correct functions", ->
    assert.isFunction trans.log

  describe "functionally", ->
    logResponse = undefined
    beforeEach (done) ->
      try
        fs.unlinkSync path.resolve "app.log"
      logger = new lumber.Logger(transports: [trans])
      logger.log "info", "A message"
      logger.on "log", (err, msg, level, name, filename) ->
        return unless msg?
        logResponse = { msg, level, name, filename }
        done err

    afterEach ->
      try
        fs.unlinkSync path.resolve "app.log"

    it "creates the proper file", () ->
      f = undefined
      try
        f = fs.statSync path.resolve "app.log"
      assert.isTrue !!f

    it "passes the correct params", () ->
      assert.equal logResponse.level, "info"
      assert.equal logResponse.name, "file"
      assert.equal logResponse.filename, path.resolve "app.log"

    it "writes properly enocoded data", () ->
      assert.equal logResponse.msg.trim(), fs.readFileSync(path.resolve("app.log"), "utf8").trim()

  logger = undefined
  describe 'rotating logs', () ->
    oldDate = undefined
    logResponse = undefined
    beforeEach (done) ->
      try
        fs.unlinkSync path.resolve "app.log"
      trans = new lumber.transports.File rotate: true
      logger = new lumber.Logger transports: [trans]
      logger.log "info", "A message, today"
      logger.on "log", (err, msg, level, name, filename) ->
        return unless msg?.match /today/
        logResponse = { msg, level, name, filename }
        done err

    afterEach ->
      try
        fs.unlinkSync path.resolve "app.log"

    it "creates the proper file", () ->
      f = undefined
      try
        f = fs.statSync path.resolve "app.log"
      assert.isTrue !!f

    it "writes properly enocoded data", () ->
      assert.equal logResponse.msg.trim(), fs.readFileSync(path.resolve("app.log"), "utf8").trim()

    describe "when the date changes", ->
      tomorrow = (Date.now() + 86400000)
      newLogFilePath = path.resolve("app.log" + "." + dateFormat Date.now(), 'mm-dd-yyyy')
      oldLogFilePath = path.resolve 'app.log'

      beforeEach (done) ->
        tk.travel tomorrow
        logger.log "info", "A message, tomorrow"
        logger.log "error", "An error from the future"
        logger.on "log", (err, msg, level, name, filename) ->
          return unless msg?.match /future/
          logResponse = { msg, level, name, filename }
          done err

      after () ->
        tk.reset()
        try
          fs.unlinkSync path.resolve newLogFilePath

      it "writes to the main log", () ->
        f = undefined
        try
          f = fs.statSync oldLogFilePath
        assert.isTrue !!f

      it "writes to the main log", () ->
        f = undefined
        try
          f = fs.statSync oldLogFilePath
        assert.isTrue !!f

      it "writes properly enocoded data", () ->
        assert.equal logResponse.msg.trim(), fs.readFileSync(newLogFilePath, "utf8").trim()
