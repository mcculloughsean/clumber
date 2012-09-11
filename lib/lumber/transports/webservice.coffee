###
@license
webservice.js: Webservice transport

(c) 2012 Panther Development
MIT LICENSE
###

#////////
# Required Includes
#/////////////////////////
util = require("util")
url = require("url")
http = require("http")
https = require("https")
lumber = require("../../lumber")

###
Webservice Transport
@implements {Transport}
###
Webservice = exports.Webservice = (options) ->
  self = this
  lumber.Transport.call self
  options = options or {}
  self.encoder = lumber.util.checkOption(options.encoder, "json")
  self.level = lumber.util.checkOption(options.level, "info")
  self.url = lumber.util.checkOption(options.url, null)
  self.method = lumber.util.checkOption(options.method, "POST")
  self.headers = lumber.util.checkOption(options.headers, null)
  self.secure = lumber.util.checkOption(options.secure, false)
  self.auth = lumber.util.checkOption(options.auth, null)
  self.name = "webservice"
  if typeof (self.encoder) is "string"
    e = lumber.util.titleCase(self.encoder)
    if lumber.encoders[e]
      self.encoder = new lumber.encoders[e]()
    else
      throw new Error("Unknown encoder passed: " + self.encoder)
  self.headers = "Content-Type": self.encoder.contentType  unless self.headers


#////////
# Inherits from EventEmitter
#/////////////////////////
util.inherits Webservice, lumber.Transport

#////////
# Public Methods
#/////////////////////////
###
Logs the string to the specified webservice
@param {object} args
@param {function} cb
###
Webservice::log = (args, cb) ->
  self = this
  msg = self.encoder.encode(args.level, args.msg, args.meta)
  opts = url.parse(self.url)
  req = undefined
  data = undefined
  secure = self.secure
  secure = true  if opts.protocol.toLowerCase() is "https:"
  opts.port = opts.port or ((if secure then 443 else 80))
  opts.method = self.method
  opts.headers = self.headers
  opts.auth = self.auth  if self.auth
  if self.secure
    req = https.request(opts)
  else
    req = http.request(opts)
  
  #setup listeners
  req.on "response", (res) ->
    res.on "data", (chunk) ->
      unless data
        data = chunk
      else
        data += chunk

    res.on "end", ->
      cb null, msg, args.level, self.name, self.url, res.statusCode, data  if cb

    res.on "close", (err) ->
      cb err, msg, args.level, self.name, self.url, res.statusCode, data  if cb


  req.on "error", (err) ->
    cb err  if cb

  
  #write msg to body
  req.write msg
  req.end()
