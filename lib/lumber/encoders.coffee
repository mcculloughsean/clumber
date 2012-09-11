###
@license
encoders.js: Include for core encoders

(c) 2012 Panther Development
MIT LICENCE
###
encoders = exports

#////////
# Required Includes
#/////////////////////////
fs = require("fs")
path = require("path")
common = require("./common")

#////////
# Setup getters for encoders
#/////////////////////////
fs.readdirSync(path.join(__dirname, "encoders")).forEach (file) ->
  
  #ignore non-js files, and base class
  return  if file.match(/\.js$/) is null or file is "encoder.js"
  e = file.replace(".js", "")
  name = common.titleCase(e)
  
  #ignore base class
  encoders.__defineGetter__ name, ->
    require("./encoders/" + e)[name]


