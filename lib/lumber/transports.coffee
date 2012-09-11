###
@license
transports.js: Include for core transports

(c) 2012 Panther Development
MIT LICENSE
###
transports = exports

#////////
# Required Includes
#/////////////////////////
fs = require("fs")
path = require("path")
common = require("./common")

#////////
# Setup getters for transports
#/////////////////////////
fs.readdirSync(path.join(__dirname, "transports")).forEach (file) ->

  #ignore non-js files, and base class
  return  if file is "transports.coffee"
  t = file.replace(/.(js|coffee)/, "")
  name = common.titleCase(t)

  #ignore base class
  transports.__defineGetter__ name, ->
    require("./transports/" + t)[name]


