###
@license
common.js: Common helpers for the entire module

(c) 2012 Panther Development
MIT LICENSE
###
common = module.exports

#////////
# Required Includes
#/////////////////////////
util = require("util")
colors = require("colors")
cycle = require("cycle")

###
Sets a variable to the default if it is unset
@return {mixed} The option set
@param {mixed} opt The option value passed
@param {mixed} val The default value to set
###
common.checkOption = (opt, val) ->
  (if typeof (opt) is "undefined" then val else opt)


###
Title cases a passed string. Changes "help" to "Help"
@return {string} Title-cased version of passes string
@param {string} str The string to captialize
###
common.titleCase = (str) ->
  lines = str.split("\n")
  lines.forEach (line, l) ->
    words = line.split(" ")
    words.forEach (word, w) ->
      words[w] = word[0].toUpperCase() + word.slice(1)

    lines[l] = words.join(" ")

  lines.join "\n"


###
Generates a random GUID
@return {string} GUID
###
common.generateGuid = ->

  ###
  Generates 4 hex characters
  @return {string} 4 character hex string
  ###
  S4 = ->
    (((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1

  S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4()


###
Padds a string to the length specified
@return {string} Padded string
@param {string} str String to pad
@param {string} pad What to pad the string with
@param {number} len The length of final string
###
common.pad = (str, pad, len) ->
  str = pad + str  while str.length < len
  str


###
Colorizes a string based on a level
@return {string} Colorized string
@param {string} str The string to colorize
@param {string} level The level the string should be colorized to
###
common.colorize = (str, level, colors) ->
  str[colors[level]]


###
Prepares an arguments array for use by a log function
@return {object} Perpares arguments for a log method
@param {array} args The arguments to prepare
###
common.prepareArgs = (args) ->
  [level, msg, meta, cb] = args
  #console.log args

  argStart = 2
  fargs = undefined
  lmsg = args[2]

  #if meta is a string, we consider it the message
  #if typeof (meta) is "string"
    #argStart = 2
    #msg = meta
    #meta = null

  #if cb is not a func, then all left are format args
  #if typeof (cb) isnt "function"
    #cb = null
    #fargs = args.slice(argStart)

  #if it is, then only upto the last item is format args
  #else
    #fargs = args.slice(argStart, args.length - 1)

  #at this point if msg is a function, its the callback
  #if typeof (msg) is "function"
    #cb = msg
    #msg = ""

  #if we have format args, then lets apply them
  #if fargs.length

    ##put msg on and apply to util.format
    #fargs.unshift msg
    #msg = util.format.apply(null, fargs)
  {level, msg, meta, cb}
