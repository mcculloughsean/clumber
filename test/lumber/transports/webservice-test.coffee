#webservice-test.js: Tests the webservice transport
#
#(c) 2012 Panther Development
#MIT LICENSE

fs = require "fs"
path = require "path"
mocha = require "mocha"
assert = require("chai").assert
lumber = require "../../../lib/lumber"

trans = undefined
describe "Webservice", ->
  beforeEach ->
    trans = new lumber.transports.Webservice()
    console.log "foo bar baz"

  it "has the correct defaults", ->
    assert.instanceOf trans.encoder, lumber.encoders.Json
    assert.isFunction trans.encoder.encode
    assert.equal trans.level, "info"
    assert.equal trans.method, "POST"
    assert.deepEqual trans.headers,
      "Content-Type": "application/json"

    assert.isNull trans.url
    assert.isNull trans.auth
    assert.isFalse trans.secure

  it "has the correct functions", ->
    assert.isFunction trans.log

  describe "functionally", ->
    logger = undefined
    beforeEach ->
      logger = new lumber.Logger(transports: [new lumber.transports.Webservice(url: "http://localhost:91234")])
      data = undefined
      that = this
      server = http.createServer((req, res) ->
        req.on "data", (chunk) ->
          unless data
            data = chunk
          else
            data += chunk

        req.on "end", ->
          res.writeHead 200,
            "Content-Type": "application/json"

          res.end JSON.stringify(works: "yeah")

      ).listen(91234, "127.0.0.1", ->
        logger.log "info", "A message"
        logger.on "log", ->
          args = Array::slice.call(arguments_)
          args.push data.toString()
          that.callback.apply that, args

      )

    "get the correct response": (err, msg, level, name, url, statusCode, resData, postData) ->
      assert.isTrue not err
      assert.equal statusCode, 200
      assert.equal resData, JSON.stringify(works: "yeah")

    "pass the correct params": (err, msg, level, name, url, statusCode, resData, postData) ->
      assert.isTrue not err
      assert.equal level, "info"
      assert.equal name, "webservice"
      assert.equal url, "http://localhost:91234"

    "post the properly encoded data": (err, msg, level, name, url, statusCode, resData, postData) ->
      assert.isTrue not err
      assert.equal msg.trim(), postData.trim()
