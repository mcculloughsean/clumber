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

trans = logger = undefined
mainLogFilePath = path.resolve 'app.log'
describe "File", ->
  beforeEach ->
    trans = new lumber.transports.File()

  it "has the correct defaults", ->
    assert.instanceOf trans.encoder, lumber.encoders.Json
    assert.isFunction trans.encoder.encode
    assert.equal trans.level, "info"
    assert.equal trans.filename, mainLogFilePath

  it "the correct functions", ->
    assert.isFunction trans.log

  describe "functionally", ->
    logResponse = undefined
    beforeEach (done) ->
      try
        fs.unlinkSync mainLogFilePath
      logger = new lumber.Logger(transports: [trans])
      logger.log "info", "A message"
      logger.on "log", (err, msg, level, name, filename) ->
        return unless msg?
        logResponse = { msg, level, name, filename }
        done err

    afterEach ->
      try
        fs.unlinkSync mainLogFilePath

    it "creates the proper file", () ->
      f = undefined
      try
        f = fs.statSync mainLogFilePath
      assert.isTrue !!f

    it "passes the correct params", () ->
      assert.equal logResponse.level, "info"
      assert.equal logResponse.name, "file"
      assert.equal logResponse.filename, mainLogFilePath

    it "writes properly enocoded data", () ->
      assert.equal logResponse.msg.trim(), fs.readFileSync(mainLogFilePath, "utf8").trim()


describe 'rotating logs', () ->
  oldDate = undefined
  logResponse = undefined
  before (done) ->
    try
      fs.unlinkSync mainLogFilePath

    trans = new lumber.transports.File rotate: true
    logger = new lumber.Logger transports: [trans]
    logger.log "info", "A message, today"

    logger.on "log", (err, msg, level, name, filename) ->
      return unless msg?.match /today/
      logResponse = { msg, level, name, filename }
      done err

  after ->
    try
      fs.unlinkSync mainLogFilePath

  it "creates the main log file", () ->
    f = undefined
    try
      f = fs.statSync mainLogFilePath
    assert.isTrue !!f

  it "writes properly enocoded data", () ->
    assert.equal logResponse.msg.trim(), fs.readFileSync(mainLogFilePath, "utf8").trim()

  describe "when the date changes", ->
    tomorrow = rotatedLogFilePath = undefined
    rotatedLogFilePath = path.resolve "app.log" + "." + dateFormat(Date.now(), 'mm-dd-yyyy')
    before (done) ->
      # Stub the date
      tomorrow = Date.now() + 86400000
      tk.travel tomorrow

      trans.on "rotate", () ->
        logger.log "info", "this should be in the main log only"
        done()
      # Send some data down the logger
      logger.log "error", "An error from the future"
      logger.on "log", (err, msg, level, name, filename) ->
        return unless msg?.match /future/
        logResponse = { msg, level, name, filename }

    after () ->
      tk.reset()
      try
        fs.unlinkSync rotatedLogFilePath

    it "has moved the running log to a timestamped log", () ->
      f = undefined
      try
        f = fs.statSync rotatedLogFilePath
      assert.isTrue !!f

    it "still has the main log file", () ->
      f = undefined
      try
        f = fs.statSync mainLogFilePath
      assert.isTrue !!f

    it "has the old events in the log", () ->
      rotatedLogFileContents = fs.readFileSync(rotatedLogFilePath, "utf8").trim()
      assert rotatedLogFileContents.match "A message, today"
      assert rotatedLogFileContents.match "An error from the future"

    it "has a new log event in the main log", () ->
      mainLogFileContents = fs.readFileSync(mainLogFilePath, "utf8").trim()
      assert mainLogFileContents.match "this should be in the main log only"

