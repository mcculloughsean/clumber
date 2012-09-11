###
console-test.js: Tests the console transport

(c) 2012 Panther Development
MIT LICENSE
###
fs = require("fs")
path = require("path")
vows = require("vows")
assert = require("assert")
cov = require("../../coverage")
lumber = cov.require("../lib/lumber")
#,
#	'should': {
#	    topic: function(con) {
#		process.stdout.on('data', this.callback);
#
#		var logger = new lumber.Logger({ transports: [con] });
#		logger.info('Some info data', this.callback);
#	    },
#	    'write to the proper stream': function(data) {
#		assert.isTrue(true);
#	    },
#	    'write properly enocoded data': function(data) {
#		assert.equal(data, 'info: Some info data');
#	    }
#	}
vows.describe("Console").addBatch("console transport":
  topic: ->
    new lumber.transports.Console()

  has:
    "the correct defaults": (con) ->
      assert.instanceOf con.encoder, lumber.encoders.Text
      assert.isFunction con.encoder.encode
      assert.equal con.level, "info"

    "the correct functions": (con) ->
      assert.isFunction con.log
).export module
