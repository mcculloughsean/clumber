###
@license
console.js: Console transport

(c) 2012 Panther Development
MIT LICENSE
###

#////////
# Required Includes
#/////////////////////////
util = require "util"
events = require "events"
lumber = require "../../lumber"

###
Console Transport
@implements {Transport}
###
class Console extends events.EventEmitter
  constructor: (options={}) ->
    super()

    @encoder = lumber.util.checkOption options.encoder, "text"
    @level = lumber.util.checkOption options.level, "info"
    @name = "console"
    if typeof (@encoder) is "string"
      e = lumber.util.titleCase(@encoder)
      if lumber.encoders[e]
        @encoder = new lumber.encoders[e]()
      else
        throw new Error("Unknown encoder passed: " + @encoder)

  #Logs the string via the stdout console
  #@param {object} args The arguments for the log
  #@param {function} cb The callback to call after logging
  log: (args, cb) ->
    self = this
    msg = @encoder.encode(args.level, args.msg, args.meta)
    if args.level is "error"
      console.error msg
    else
      console.log msg
    cb null, msg, args.level, @name  if cb


module.exports.Console = Console
