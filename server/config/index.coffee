fs     = require "fs"
_      = require "lodash"
chalk  = require "chalk"
root   = require 'app-root-path'


config =
  isDev: ->
    return not process.env.NODE_ENV || process.env.NODE_ENV == "development";
  isProd: ->
    return process.env.NODE_ENV == "production";

  ip: process.env.NODE_IP || "0.0.0.0",
  port: process.env.PORT || 2000,
  sessions:
    # Cookie key name
    name: "sessionId",
    # Mongo store collection name
    collection: "sessions"
    autoReconnect: true
    autoRemove: 'interval'
    autoRemoveInterval: 10 # default
    cookie:
      # session expiration is set by default to one week
      maxAge: 7 * 24 * (60 * 60 * 1000)
      # httpOnly flag makes sure the cookie is only accessed through the HTTP protocol and not JS/browser
      httpOnly: true
      # secure cookie should be turned to true to provide additional layer of security so that the cookie is set only when working in HTTPS mode.
      secure: false

  hashSecret: "71IIYMzMb0egTaCvvdijhUajAOjsrurzyRX5ziskMk4"
  sessionSecret: "MB9x-hOkx-UdcCbOprxggu-Wv1PetuoqzBny1h8DULA"

  db:
    server: 'mongodb://localhost:27017/era'
    options:
      useUnifiedTopology: true
      useCreateIndex: true
      useNewUrlParser: true
  redis:
    enabled: false

  logging:
    file:
      enabled: false
      path: root.resolve("logs")
      level: "info"
      json: false
      exceptionFile: true

  console:
    level: "debug"

if config.isProd()
  _.extend config, require('./prod')

module.exports = config