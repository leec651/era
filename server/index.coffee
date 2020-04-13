moment  = require 'moment'
config  = require './config'
logger  = require './core/logger'
{pink}  = require './core/chalk'
app     = require './core/express'


app.listen config.port, config.ip, () ->
  logger.info "Env    " + pink(process.env.NODE_ENV)
  logger.info "IP     " + pink(config.ip)
  logger.info "Port   " + pink(config.port)
  logger.info "DB     " + pink(config.db.server)
  logger.info "Redis  " + pink(if config.redis.enabled then config.redis.uri else "Disabled")

exports = module.exports = app