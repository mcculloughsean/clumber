###
@license
transport.js: Base Transport interface

(c) 2012 Panther Development
MIT LICENSE
###

#////////
# Required Includes
#/////////////////////////
events = require("events")
util = require("util")

###
Base Transport
@interface
###
class Transport extends events.EventEmitter
  constructor: (options) ->
    events.EventEmitter.call this

  #Logs the string via this transport, using
  #the encoder specified
  #@param {object} args The arguments for the log

  log: (args) ->


module.exports.Transport = Transport
