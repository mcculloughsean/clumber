###
@license
text.js: Text Encoder

(c) 2012 Panther Development
MIT LICENSE
###

#////////
# Required Includes
#/////////////////////////
util = require("util")
dateFormat = require("dateformat")
eyes = require("eyes")
common = require("../common")
Encoder = require("./encoder").Encoder

###
Text Encoder
@constructor
@implements {Encoder}
###
Text = exports.Text = (options) ->
  self = this
  Encoder.call self
  options = options or {}
  self.colorize = common.checkOption(options.colorize, true)
  self.timestamp = common.checkOption(options.timestamp, false)
  self.headFormat = common.checkOption(options.headFormat, "%l: ")
  self.dateFormat = common.checkOption(options.dateFormat, "isoDateTime")
  self.inspect = eyes.inspector(stream: null)
  self.contentType = "text/plain"
  self.encoding = "utf8"


#////////
# Inherits from Encoder
#/////////////////////////
util.inherits Text, Encoder

#////////
# Public Methods
#/////////////////////////
###
Encodes the passed string into CSV Text
@return {string} Encoded string
@param {string} level The level of this message
@param {string} msg The message to encode
@param {object} meta The metadata of this log
###
Text::encode = (level, msg, meta) ->
  self = this
  head = ((if self.colorize and self.colors then self.headFormat.replace("%l", common.colorize(level.toLowerCase(), level, self.colors)).replace("%L", common.colorize(level.toUpperCase(), level, self.colors)) else self.headFormat.replace("%l", level.toLowerCase()).replace("%L", level.toUpperCase())))
  time = dateFormat(new Date(), self.dateFormat)
  
  #have to color the meta cyan since that is default
  #color for eyes, and there is a glitch that doesn't
  #color the entire object on null streams.
  #This should really be changed to use w/e the color is set for
  #ALL in eyes instead of assuming cyan
  head + ((if self.timestamp then "(" + time + ") " else "")) + msg + self._encodeMeta(meta)

Text::_encodeMeta = (meta) ->
  self = this
  return ""  unless meta
  
  #special error formatting
  if meta.constructor is Error
    c = (if self.colorize then self.colors.error or "red" else null)
    msg = []
    props = ["message", "name", "type", "stack", "arguments"]
    temp = undefined
    props.forEach (prop) ->
      
      #if prop doesnt exist, move on
      return  unless meta[prop]
      
      #setup title
      if prop is "stack"
        temp = "  Stack Trace"
      else
        temp = "  Error " + common.titleCase(prop)
      
      #color if necessary, and add value
      temp = ((if c then temp[c] else temp))
      temp += ": " + ((if prop is "stack" then "\n  " else "")) + meta[prop]
      
      #add to message
      msg.push temp

    return "\n" + msg.join("\n")
  
  #if not special case, just inspect with eyes
  "\n\u001b[36m" + self.inspect(meta)
