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
class Webservice extends lumber.Transport
  constructor: (options) ->
    lumber.Transport.call self
    options = options or {}
    @encoder = lumber.util.checkOption(options.encoder, "json")
    @level = lumber.util.checkOption(options.level, "info")
    @url = lumber.util.checkOption(options.url, null)
    @method = lumber.util.checkOption(options.method, "POST")
    @headers = lumber.util.checkOption(options.headers, null)
    @secure = lumber.util.checkOption(options.secure, false)
    @auth = lumber.util.checkOption(options.auth, null)
    @name = "webservice"
    if typeof (@encoder) is "string"
      e = lumber.util.titleCase(@encoder)
      if lumber.encoders[e]
        @encoder = new lumber.encoders[e]()
      else
        throw new Error("Unknown encoder passed: " + @encoder)
    @headers = "Content-Type": self.encoder.contentType  unless self.headers



  #////////
  # Public Methods
  #/////////////////////////
  ###
  Logs the string to the specified webservice
  @param {object} args
  @param {function} cb
  ###
  log: (args, cb) ->
    msg = @encoder.encode(args.level, args.msg, args.meta)
    opts = url.parse(@url)
    req = undefined
    data = undefined
    secure = @secure
    secure = true  if opts.protocol.toLowerCase() is "https:"
    opts.port = opts.port or ((if secure then 443 else 80))
    opts.method = @method
    opts.headers = @headers
    opts.auth = @auth  if self.auth
    if @secure
      req = https.request(opts)
    else
      req = http.request(opts)

    #setup listeners
    req.on "response", (res) =>
      res.on "data", (chunk) =>
        unless data
          data = chunk
        else
          data += chunk

      res.on "end", =>
        cb null, msg, args.level, @name, self.url, res.statusCode, data  if cb

      res.on "close", (err) =>
        cb err, msg, args.level, @name, self.url, res.statusCode, data  if cb


    req.on "error", (err) =>
      cb err  if cb


    #write msg to body
    req.write msg
    req.end()

module.exports.Webservice=Webservice
