# test/coverage.js
covererageOn = process.argv.some((arg) ->
  (/^--cover/).test arg
)
if covererageOn
  
  #console.log('Code coverage on');
  exports.require = (path) ->
    instrumentedPath = path.replace("/lib", "/lib-cov")
    try
      require.resolve instrumentedPath
      return require(instrumentedPath)
    catch e
      
      #console.log('Coverage on, but no instrumented file found at '
      #+ instrumentedPath);
      return require(path)
else
  
  #console.log('Code coverage off');
  exports.require = require
