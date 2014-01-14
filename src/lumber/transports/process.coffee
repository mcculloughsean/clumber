util = require "util"
cp = require "child_process"
path = require "path"
events = require "events"
dateFormat = require "dateformat"
lumber = require "../../lumber"

throwError = (command, args, error) ->
  console.error "Error during lumber Process transport: #{command} #{args.join(' ')}"
  console.error error.stack
  process.exit(99)

class Process extends events.EventEmitter
  constructor: (options={}) ->
    super()

    # Format [ "command", "list", "of", "args" ]
    @arguments = lumber.util.checkOption options.command, ['tee', '/dev/null']
    @encoder = lumber.util.checkOption options.encoder, "json"
    @level = lumber.util.checkOption options.level, "info"
    @name = "process"
    if typeof (@encoder) is "string"
      e = lumber.util.titleCase(@encoder)
      if lumber.encoders[e]
        @encoder = new lumber.encoders[e]()
      else
        throw new Error("Unknown encoder passed: " + @encoder)
    @encoding = @encoder.encoding

    @command = @arguments.shift()
    @_childProcess = cp.spawn @command, @arguments
    @_childProcess.on 'error', (error) =>
      throwError @command, @arguments, error
    @_childProcess.stdout.pipe(process.stdout)

  log: (args, cb) ->
    msg = @encoder.encode args.level, args.msg, args.meta
    @_write msg + "\n", (err) =>
      cb err, msg, args.level, @name  if cb

  _write: (data, cb) ->
    @_childProcess.stdin.write data, @encoding, cb

module.exports = { Process }
