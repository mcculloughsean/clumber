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
  todaysDate = undefined
  constructor: (options={}) ->
    super()

    @encoder = lumber.util.checkOption options.encoder, "json"
    @level = lumber.util.checkOption options.level, "info"
    @filename = lumber.util.checkOption options.filename, path.resolve("app.log")
    @filemode = lumber.util.checkOption options.filemode, "0666"
    @maxsize = lumber.util.checkOption options.maxsize, 52428800  #50MB
    @rotate = lumber.util.checkOption options.rotate, false
    @_size = 0
    @_buffer = []
    @name = "file"
    if typeof (@encoder) is "string"
      e = lumber.util.titleCase(@encoder)
      if lumber.encoders[e]
        @encoder = new lumber.encoders[e]()
      else
        throw new Error("Unknown encoder passed: " + @encoder)
    @encoding = @encoder.encoding
    todaysDate = new Date()

  #Logs the string to the specified file
  #@param {object} args The arguments for the log
  #@param {function} cb The callback to call when completed

  log: (args, cb) ->
    msg = @encoder.encode args.level, args.msg, args.meta
    @_open (buff) =>
      if buff
        @_buffer.push [msg, args, cb]
      else
        @_write msg + "\n", (err) =>
          cb err, msg, args.level, @name, @filename  if cb


  _write: (data, cb) ->
    #add size of this new message
    @_size += data.length

    #write to stream
    flushed = @_stream.write data, @encoding
    if flushed

      #check if logs need to be rotated
      if @_needsToRotateLogs()
        @_rotateLogs (err) ->
          todaysDate = new Date()
          cb err  if cb

      else
        cb null  if cb
    else

      #after msg is drained
      @_drain =>

        #check if logs need to be rotated
        if @_needsToRotateLogs()
          @_rotateLogs (err) ->
            todaysDate = new Date()
            cb err  if cb

        else
          cb null  if cb


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

      #@_stream = null
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

    shouldIRotate = !(d.getDate() == todaysDate.getDate() and
      d.getMonth() == todaysDate.getMonth() and
      d.getYear() == todaysDate.getYear())

    return @rotate and shouldIRotate

  _rotateLogs: (cb) ->

    @_close =>
      #setup filenames to move
      from = @filename
      to = @filename + "." + dateFormat todaysDate, 'mm-dd-yyyy'

      #move files
      fs.rename from, to, (err) =>
        console.log "renaming file #{from} #{to}", err
        return cb err  if cb and err
        @emit 'rotate'
        return cb()

module.exports.File = File
