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
util = require("util")
fs = require("fs")
path = require("path")
lumber = require("../../lumber")

###
File Transport
@constructor
@implements {Transport}
###
class File extends lumber.Transport

  constructor: (options) ->
    lumber.Transport.call this
    options = options or {}
    @encoder = lumber.util.checkOption options.encoder, "json"
    @level = lumber.util.checkOption options.level, "info"
    @filename = lumber.util.checkOption options.filename, path.resolve("app.log")
    @filemode = lumber.util.checkOption options.filemode, "0666"
    @maxsize = lumber.util.checkOption options.maxsize, 52428800  #50MB
    @rotate = lumber.util.checkOption options.rotate, 10
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
      if @maxsize and @_size >= @maxsize
        @_rotateLogs (err) ->
          @_size = 0
          cb err  if cb

      else
        cb null  if cb
    else

      #after msg is drained
      @_drain =>

        #check if logs need to be rotated
        if @maxsize and @_size >= @maxsize
          @_rotateLogs (err) =>
            @_size = 0
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

      #check file sizes for rotation
      @_checkSize (err) ->

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
      @_stream.end()
      @_stream.destroySoon()
      @_drain =>
        @emit "closed"
        cb null  if cb

      @_stream = null
    else
      @_stream = null
      cb null  if cb

  _drain: (cb) ->

    #easy way to handle drain callback
    @_stream.once "drain", =>
      @emit "drain"
      cb()  if cb


  _flush: (cb) ->
    self = this
    if @_buffer.length is 0
      @emit "flush"
      cb null  if cb
      return

    #start a write for each one
    @_buffer.forEach (log) ->
      ((msg, args, cb) ->
        process.nextTick ->
          @_write msg + "\n", (err) ->
            cb err, msg, args.level, @name, @filename  if cb


      ).apply self, log


    #after writes are started clear buffer
    @_buffer.length = 0

    #emit flush after the stream drains
    @_drain ->
      @emit "flush"
      cb null  if cb


  _checkSize: (cb) ->
    self = this

    #check size of file
    fs.stat @filename, (err, stats) ->

      #if err and error isnt that it doesnt exist
      if err and err.code isnt "ENOENT"
        cb err  if cb
        return
      @_size = ((if stats then stats.size else 0))

      #if the size is >= maxsize, rotate files
      if @_size >= @maxsize
        @_size = 0
        @_rotateLogs cb
      else
        cb null


  _rotateLogs: (cb) ->
    self = this
    max = 1
    exists = false

    #keep going until we find max number that doesn't exist
    loop
      try
        fs.lstatSync @filename + "." + max
        exists = true
        max++
      catch e
        exists = false
      break unless exists
    @_close ->

      #loop through each file and move their numbers up
      @_doLogRotate max, (err) ->
        if err
          cb err  if cb
          return
        @emit "rotate"

        #if the max file is more than how many we keep remove it
        if max > @rotate
          fs.unlink @filename + "." + max, (err) ->
            cb err  if cb

        else
          cb null  if cb



  _doLogRotate: (num, cb) ->
    self = this

    #if we at 0 we are done
    unless num
      cb null  if cb
      return

    #setup filenames to move
    from = @filename + ((if num > 1 then "." + (num - 1) else ""))
    to = @filename + "." + num

    #move files
    fs.rename from, to, (err) ->
      if err
        cb err  if cb
        return

      #move the next one
      num--
      @_doLogRotate num, cb

module.exports.File = File
