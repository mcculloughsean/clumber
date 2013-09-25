###
@license
json.js: JSON Encoder

(c) 2012 Panther Development
MIT LICENSE
###

#////////
# Required Includes
#/////////////////////////
util = require "util"
events = require "events"
dateFormat = require "dateformat"
jsonSafe = require "json-stringify-safe"
{pick, omit} = require "underscore"
common = require "../common"

###
JSON Encoder
@constructor
@implements {Encoder}
###
class Json extends events.EventEmitter
  constructor: (options) ->
    super()
    options = options or {}
    @colorize = common.checkOption options.colorize, false
    @headFormat = common.checkOption options.headFormat, "%L"
    @dateFormat = common.checkOption options.dateFormat, "isoDateTime"
    @contentType = "application/json"
    @encoding = "utf8"


  _outputFormat: (obj) ->
    jsonPair = (key, value) ->
      "#{jsonSafe(key)}:#{jsonSafe(value)}"

    orderedInnerStringify = (obj, keys) ->
      (jsonPair key, obj[key] for key in keys).join ','

    prioritizedKeys = ['timestamp', 'level']
    prioritized = pick obj, prioritizedKeys
    rest = omit obj, prioritizedKeys

    restOfJson = jsonSafe rest
    prioritizedJson = orderedInnerStringify obj, prioritizedKeys
    prioritizedJson += ',' if restOfJson.length > 2

    output = '{' + prioritizedJson + restOfJson.slice 1


  #////////
  # Public Methods
  #/////////////////////////
  ###
  Encodes the passed string into JSON format
  @return {string} Encoded string
  @param {string} level The level of this message
  @param {string} msg The message to encode
  @param {object} meta The metadata of this log
  ###
  encode: (level, msg, meta) ->
    self = this
    head = @headFormat.replace("%l", level.toLowerCase()).replace("%L", level.toUpperCase())
    time = dateFormat(new Date(), @dateFormat)
    obj =
      level: level
      head: head
      message: msg

    obj.timestamp = time
    obj.meta = meta  if meta
    @_outputFormat obj

module.exports = Json
