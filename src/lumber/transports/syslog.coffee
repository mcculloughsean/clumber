###
@license
Syslog transport

MIT LICENSE
###

#////////
# Required Includes
#/////////////////////////
util = require "util"
events = require "events"
lumber = require "../../lumber"
syslog = require 'node-syslog'

###
Syslog Transport
@implements {Transport}
###
class Syslog extends events.EventEmitter
  constructor: (options={}) ->
    super()

    @encoder = lumber.util.checkOption options.encoder, "text"
    @level = lumber.util.checkOption options.level, "info"
    @syslogname = lumber.util.checkOption options.syslogname, "clumber"
    @syslogfacility = lumber.util.checkOption options.syslogfacility, syslog.LOG_LOCAL2
    @name = "syslog"
    syslog.init @syslogname, syslog.LOG_PID | syslog.LOG_ODELAY, @syslogfacility
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
    syslog.log syslog.LOG_INFO, msg
    cb null, msg, args.level, @name  if cb

module.exports.Syslog = Syslog
