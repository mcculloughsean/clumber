
/*
@license
Syslog transport

MIT LICENSE
*/

(function() {
  var Syslog, events, lumber, syslog, util,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  util = require("util");

  events = require("events");

  lumber = require("../../lumber");

  syslog = require('node-syslog');

  /*
  Syslog Transport
  @implements {Transport}
  */

  Syslog = (function(_super) {

    __extends(Syslog, _super);

    function Syslog(options) {
      var e;
      if (options == null) options = {};
      Syslog.__super__.constructor.call(this);
      this.encoder = lumber.util.checkOption(options.encoder, "text");
      this.level = lumber.util.checkOption(options.level, "info");
      this.syslogname = lumber.util.checkOption(options.syslogname, "clumber");
      this.syslogfacility = lumber.util.checkOption(options.syslogfacility, syslog.LOG_LOCAL2);
      this.name = "syslog";
      syslog.init(this.syslogname, syslog.LOG_PID | syslog.LOG_ODELAY, this.syslogfacility);
      if (typeof this.encoder === "string") {
        e = lumber.util.titleCase(this.encoder);
        if (lumber.encoders[e]) {
          this.encoder = new lumber.encoders[e]();
        } else {
          throw new Error("Unknown encoder passed: " + this.encoder);
        }
      }
    }

    Syslog.prototype.log = function(args, cb) {
      var msg, self;
      self = this;
      msg = this.encoder.encode(args.level, args.msg, args.meta);
      syslog.log(syslog.LOG_INFO, msg);
      if (cb) return cb(null, msg, args.level, this.name);
    };

    return Syslog;

  })(events.EventEmitter);

  module.exports.Syslog = Syslog;

}).call(this);
