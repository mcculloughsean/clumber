###
@license
file.js: File transport

Liberal inspiration taken from https://github.com/flatiron/winston

(c) 2012 Panther Development
MIT LICENSE
###

#////////
# Required Includes
#/////////////////////////
util = require "util"
fs = require "fs"
path = require "path"
events = require "events"
dateFormat = require "dateformat"
lumber = require "../../lumber"

###
File Transport
@constructor
@implements {Transport}
###
class File extends events.EventEmitter
  @_todaysDate = undefined
  constructor: (options={}) ->
    super()

    @encoder = lumber.util.checkOption options.encoder, "json"
    @level = lumber.util.checkOption options.level, "info"
    @filename = lumber.util.checkOption options.filename, path.resolve("app.log")
    @filemode = lumber.util.checkOption options.filemode, "0666"
    @rotate = lumber.util.checkOption options.rotate, false
    @_rotating = false
    @_buffer = []
    @name = "file"
    if typeof (@encoder) is "string"
      e = lumber.util.titleCase(@encoder)
      if lumber.encoders[e]
        @encoder = new lumber.encoders[e]()
      else
        throw new Error("Unknown encoder passed: " + @encoder)
    @encoding = @encoder.encoding
    @_todaysDate = new Date()

  #Logs the string to the specified file
  #@param {object} args The arguments for the log
  #@param {function} cb The callback to call when completed

  log: (args, cb) ->
    msg = @encoder.encode args.level, args.msg, args.meta
    @_open (buff) =>
      if buff or @_rotating
        @_buffer.push [msg, args, cb]
      else
        @_write msg + "\n", (err) =>
          cb err, msg, args.level, @name, @filename  if cb


  _write: (data, cb) ->
    if @_stream.write data, @encoding
      #check if logs need to be rotated
      @_rotateLogsIfNecessary cb

    else
      #after msg is drained
      @_drain =>
        #check if logs need to be rotated
        @_rotateLogsIfNecessary cb


  _rotateLogsIfNecessary: (cb) ->
    if @_needsToRotateLogs()
      @_rotateLogs (err) =>
        @_todaysDate = new Date()
        cb err if cb
    else
      cb null if cb

  # Helper to open up a new stream. This function is called every time write is called.
  # It takes a callback that is called with either 'true' or 'false' depending on the state
  # of the stream
  # 'false' means that the message should be buffered and then written to the stream when
  # the 'flush' command is run it will drain all the buffered messages to the stream
  # and emit a 'drain' event
  # 'true' means the message was directly written to file
  _open: (cb) ->
    if @_opening
      cb true  if cb

    else if @_stream
      #already have an open stream
      cb false  if cb

    else
      #need to open new stream, buffer msg
      cb true  if cb

      #after rotation create stream
      @_stream = fs.createWriteStream @filename,
        flags: "a"
        encoding: @encoding
        mode: @fileMode

      @_stream.setMaxListeners Infinity

      @once "flush", =>
        @_opening = false
        @emit "open", @filename

      @_flush()


  _close: (cb) ->
    if @_stream
      @_stream.on 'close', ->
        @emit "closed"
        cb null  if cb
      @_stream.end()
      @_stream.destroySoon()

      @_stream = null
    else
      @_stream = null
      cb null  if cb

  _drain: (cb) ->
    #easy way to handle drain callback
    @_stream.once "drain", =>
      @emit "drain"
      cb()  if cb


  _flush: (cb) =>
    if @_buffer.length is 0
      @emit "flush"
      cb null if cb
      return

    #start a write for each one
    @_buffer.forEach (log) =>
      [msg, args, cb] = log
      process.nextTick =>
        @_write msg + "\n", (err) =>
          cb err, msg, args.level, @name, @filename  if cb

    #after writes are started clear buffer
    @_buffer.length = 0

    #emit flush after the stream drains
    @_drain =>
      @emit "flush"
      cb null  if cb


  _needsToRotateLogs: () ->
    d = new Date()

    shouldIRotate = !(d.getDate() == @_todaysDate.getDate() and
      d.getMonth() == @_todaysDate.getMonth() and
      d.getYear() == @_todaysDate.getYear())

    return !@_rotating and @rotate and shouldIRotate

  _rotateLogs: (cb) ->
    @_rotating = true
    @_close =>
      #setup filenames to move
      from = @filename
      to = @filename + "." + dateFormat @_todaysDate, 'mm-dd-yyyy'

      #move files
      fs.rename from, to, (err) =>
        @_rotating = false

        return cb err  if cb and err

        @emit 'rotate'
        @_flush()
        return cb()

module.exports.File = File
