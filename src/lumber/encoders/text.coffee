###
@license
text.js: Text Encoder

(c) 2012 Panther Development
MIT LICENSE
###

#////////
# Required Includes
#/////////////////////////
util = require "util"
events = require "events"
dateFormat = require "dateformat"
eyes = require "eyes"
common = require "../common"

###
Text Encoder
@constructor
@implements {Encoder}
###
class Text extends events.EventEmitter
  constructor: (options={}) ->
    super()

    @colorize = common.checkOption options.colorize, true
    @timestamp = common.checkOption options.timestamp, false
    @headFormat = common.checkOption options.headFormat, "%l: "
    @dateFormat = common.checkOption options.dateFormat, "isoDateTime"
    @metaFormatter = common.checkOption options.metaFormatter, @_metaFormatter
    @inspect = eyes.inspector stream: null
    @contentType = "text/plain"
    @encoding = "utf8"


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
  encode: (level, msg, meta) ->
    head = if @colorize and @colors
      @headFormat.replace("%l", common.colorize(level.toLowerCase(), level, @colors)).replace("%L", common.colorize(level.toUpperCase(), level, @colors))
    else
      @headFormat.replace("%l", level.toLowerCase()).replace("%L", level.toUpperCase())
    time = dateFormat(new Date(), @dateFormat)

    #have to color the meta cyan since that is default
    #color for eyes, and there is a glitch that doesn't
    #color the entire object on null streams.
    #This should really be changed to use w/e the color is set for
    #ALL in eyes instead of assuming cyan
    head + (if @timestamp then "(" + time + ") " else "") + msg + @_encodeMeta(meta)

  _encodeMeta: (meta) ->
    return ""  unless meta
    #special error formatting
    if meta.constructor is Error and false
      c = (if @colorize then @colors.error or "red" else null)
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
        temp = if c then temp[c] else temp
        temp += ": " + (if prop is "stack" then "\n  " else "") + meta[prop]

        #add to message
        msg.push temp

      return "\n" + msg.join("\n")

    @metaFormatter meta

  _metaFormatter: (meta) ->
    #if not special case, just inspect with eyes
    "\n\u001b[36m" + @inspect(meta)

module.exports = Text
