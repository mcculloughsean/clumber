###
@license
console.js: Console transport

(c) 2012 Panther Development
MIT LICENSE
###

#////////
# Required Includes
#/////////////////////////
util = require("util")
lumber = require("../../lumber")

###
Console Transport
@implements {Transport}
###
Console = exports.Console = (options) ->
  self = this
  lumber.Transport.call self
  options = options or {}
  self.encoder = lumber.util.checkOption(options.encoder, "text")
  self.level = lumber.util.checkOption(options.level, "info")
  self.name = "console"
  if typeof (self.encoder) is "string"
    e = lumber.util.titleCase(self.encoder)
    if lumber.encoders[e]
      self.encoder = new lumber.encoders[e]()
    else
      throw new Error("Unknown encoder passed: " + self.encoder)


#////////
# Inherits from EventEmittxer
#/////////////////////////
util.inherits Console, lumber.Transport

#////////
# Public Methods
#/////////////////////////
###
Logs the string via the stdout console
@param {object} args The arguments for the log
@param {function} cb The callback to call after logging
###
Console::log = (args, cb) ->
  self = this
  msg = self.encoder.encode(args.level, args.msg, args.meta)
  if args.level is "error"
    console.error msg
  else
    console.log msg
  cb null, msg, args.level, self.name  if cb
