config  = require '../config'

module.exports = (app) ->

  require('./file')(app)
  require('./record')(app)
