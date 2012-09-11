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
File = exports.File = (options) ->
  self = this
  lumber.Transport.call self
  options = options or {}
  self.encoder = lumber.util.checkOption(options.encoder, "json")
  self.level = lumber.util.checkOption(options.level, "info")
  self.filename = lumber.util.checkOption(options.filename, path.resolve("app.log"))
  self.filemode = lumber.util.checkOption(options.filemode, "0666")
  self.maxsize = lumber.util.checkOption(options.maxsize, 52428800) #50MB
  self.rotate = lumber.util.checkOption(options.rotate, 10)
  self._size = 0
  self._buffer = []
  self.name = "file"
  if typeof (self.encoder) is "string"
    e = lumber.util.titleCase(self.encoder)
    if lumber.encoders[e]
      self.encoder = new lumber.encoders[e]()
    else
      throw new Error("Unknown encoder passed: " + self.encoder)
  self.encoding = self.encoder.encoding


#////////
# Inherits from EventEmitter
#/////////////////////////
util.inherits File, lumber.Transport

#////////
# Public Methods
#/////////////////////////
###
Logs the string to the specified file
@param {object} args The arguments for the log
@param {function} cb The callback to call when completed
###
File::log = (args, cb) ->
  self = this
  msg = self.encoder.encode(args.level, args.msg, args.meta)
  self._open (buff) ->
    if buff
      self._buffer.push [msg, args, cb]
    else
      self._write msg + "\n", (err) ->
        cb err, msg, args.level, self.name, self.filename  if cb




#////////
# Public Methods
#/////////////////////////
File::_write = (data, cb) ->
  self = this
  
  #add size of this new message
  self._size += data.length
  
  #write to stream
  flushed = self._stream.write(data, self.encoding)
  if flushed
    
    #check if logs need to be rotated
    if self.maxsize and self._size >= self.maxsize
      self._rotateLogs (err) ->
        self._size = 0
        cb err  if cb

    else
      cb null  if cb
  else
    
    #after msg is drained
    self._drain ->
      
      #check if logs need to be rotated
      if self.maxsize and self._size >= self.maxsize
        self._rotateLogs (err) ->
          self._size = 0
          cb err  if cb

      else
        cb null  if cb


File::_open = (cb) ->
  self = this
  if self._opening
    cb true  if cb
  else if self._stream
    
    #already have an open stream
    cb false  if cb
  else
    
    #need to open new stream, buffer msg
    cb true  if cb
    
    #check file sizes for rotation
    self._checkSize (err) ->
      
      #after rotation create stream
      self._stream = fs.createWriteStream(self.filename,
        flags: "a"
        encoding: self.encoding
        mode: self.fileMode
      )
      self._stream.setMaxListeners Infinity
      self.once "flush", ->
        self._opening = false
        self.emit "open", self.filename

      self._flush()


File::_close = (cb) ->
  self = this
  if self._stream
    self._stream.end()
    self._stream.destroySoon()
    self._drain ->
      self.emit "closed"
      cb null  if cb

    self._stream = null
  else
    self._stream = null
    cb null  if cb

File::_drain = (cb) ->
  self = this
  
  #easy way to handle drain callback
  self._stream.once "drain", ->
    self.emit "drain"
    cb()  if cb


File::_flush = (cb) ->
  self = this
  if self._buffer.length is 0
    self.emit "flush"
    cb null  if cb
    return
  
  #start a write for each one
  self._buffer.forEach (log) ->
    ((msg, args, cb) ->
      process.nextTick ->
        self._write msg + "\n", (err) ->
          cb err, msg, args.level, self.name, self.filename  if cb


    ).apply self, log

  
  #after writes are started clear buffer
  self._buffer.length = 0
  
  #emit flush after the stream drains
  self._drain ->
    self.emit "flush"
    cb null  if cb


File::_checkSize = (cb) ->
  self = this
  
  #check size of file
  fs.stat self.filename, (err, stats) ->
    
    #if err and error isnt that it doesnt exist
    if err and err.code isnt "ENOENT"
      cb err  if cb
      return
    self._size = ((if stats then stats.size else 0))
    
    #if the size is >= maxsize, rotate files
    if self._size >= self.maxsize
      self._size = 0
      self._rotateLogs cb
    else
      cb null


File::_rotateLogs = (cb) ->
  self = this
  max = 1
  exists = false
  
  #keep going until we find max number that doesn't exist
  loop
    try
      fs.lstatSync self.filename + "." + max
      exists = true
      max++
    catch e
      exists = false
    break unless exists
  self._close ->
    
    #loop through each file and move their numbers up
    self._doLogRotate max, (err) ->
      if err
        cb err  if cb
        return
      self.emit "rotate"
      
      #if the max file is more than how many we keep remove it
      if max > self.rotate
        fs.unlink self.filename + "." + max, (err) ->
          cb err  if cb

      else
        cb null  if cb



File::_doLogRotate = (num, cb) ->
  self = this
  
  #if we at 0 we are done
  unless num
    cb null  if cb
    return
  
  #setup filenames to move
  from = self.filename + ((if num > 1 then "." + (num - 1) else ""))
  to = self.filename + "." + num
  
  #move files
  fs.rename from, to, (err) ->
    if err
      cb err  if cb
      return
    
    #move the next one
    num--
    self._doLogRotate num, cb

