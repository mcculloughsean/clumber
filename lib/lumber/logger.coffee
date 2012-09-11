###
@license
logger.js: Core logger functionality

(c) 2012 Panther Development
MIT LICENSE
###

#////////
# Required Includes
#/////////////////////////
events = require("events")
util = require("util")
async = require("async")
lumber = require("../lumber")
Stream = require("stream").Stream

###
Core Logger class that does the work of logging
via one or more transports
@constructor
@param {object} options The options for this logger
###
Logger = exports.Logger = (options) ->
  self = this
  events.EventEmitter.call self
  options = options or {}
  self.levels = options.levels or lumber.defaults.levels
  self.colors = options.colors or lumber.defaults.colors
  self.transports = options.transports or [new lumber.transports.Console()]
  self.level = options.level or "info"
  
  #create functions for log levels
  Object.keys(self.levels).forEach (key) ->
    self[key] = ->
      args = Array::slice.call(arguments_)
      args.unshift key
      self.log.apply self, args

  
  #pass alongs
  self.transports.forEach (trans) ->
    trans.parent = self
    trans.encoder.colors = self.colors



#////////
# Inherits from EventEmitter
#/////////////////////////
util.inherits Logger, events.EventEmitter

#////////
# Public Methods
#/////////////////////////
Logger::log = ->
  self = this
  args = lumber.util.prepareArgs(Array::slice.call(arguments_))
  cb = args.cb
  done = 0
  errors = []
  async.forEach self.transports, ((trans, next) ->
    
    #if we aren't a silent level &&
    #this isn't a silent log &&
    #this log's level <= this transport's level
    if self.levels[self.level] >= 0 and self.levels[args.level] >= 0 and self.levels[args.level] <= self.levels[trans.level]
      trans.log args, ->
        a = Array::slice.call(arguments_)
        a.unshift "log"
        self.emit.apply self, a
        next()

    else
      next()
  ), (err) ->
    self.emit "logged", err
    cb err  if cb

