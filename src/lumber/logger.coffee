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

class Logger extends events.EventEmitter
  constructor: (options={}) ->
    super()
    @levels = options.levels or lumber.defaults.levels
    @colors = options.colors or lumber.defaults.colors
    @transports = options.transports or [new lumber.transports.Console()]
    @level = options.level or "info"

    #create functions for log levels
    Object.keys(@levels).forEach (key) =>
      this[key] = =>
        args = Array::slice.call(arguments)
        args.unshift key
        @log.apply this, args


    #pass alongs
    @transports.forEach (trans) ->
      trans.parent = this
      trans.encoder.colors = @colors

  #////////
  # Public Methods
  #/////////////////////////
  log: =>
    args = lumber.util.prepareArgs(Array::slice.call(arguments))
    cb = args.cb
    done = 0
    errors = []
    async.forEach @transports, (trans, next) =>
      #if we aren't a silent level &&
      #this isn't a silent log &&
      #this log's level <= this transport's level
      if @levels[@level] >= 0 and @levels[args.level] >= 0 and @levels[args.level] <= @levels[trans.level]
        trans.log args, =>
          a = Array::slice.call(arguments)
          a.unshift "log"
          console.log "emitting a log event, there are #{@transports.length} transports "
          @emit.apply this, a
          next()

      else
        next()
    , (err) =>
      @emit "logged", err
      cb err  if cb

module.exports = Logger
