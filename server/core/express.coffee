express       = require 'express'
session       = require 'express-session'
moment        = require 'moment'
compress      = require 'compression'
bodyParser    = require 'body-parser'
override      = require 'method-override'
cookieParser  = require 'cookie-parser'
i18n          = require 'i18n'
cors          = require 'cors'
compression   = require 'compression'
helmet        = require 'helmet'
crossdomain   = require 'helmet-crossdomain'
root          = require 'app-root-path'

pkg           = require root.resolve 'package.json'
config        = require '../config'
{blue}        = require './chalk'
logger        = require './logger'
passport      = require './passport'
db            = require './mongo'
MongoStore    = require('connect-mongo')(session)


setUpText = (item) ->
  logger.info "Set up #{blue(item)}"

initMiddleware = (app) ->
  setUpText "compressor"
  app.use compress
    filter: (req, res) ->
      return /json|text|javascript|css/.test(res.getHeader("Content-Type"));
    level: 3,
    threshold: 512

  setUpText "body parser"
  app.use bodyParser.urlencoded
    extended: true
    limit: config.contentMaxLength * 2

  setUpText "i18n"
  i18n.configure({
    locales: ['en', 'es']
    directory: root.resolve('locales')
    defaultLocale: 'en'
    objectNotation: true
  })
  app.use(i18n.init)

  setUpText "compression"
  app.use(compression())
  setUpText "cors"
  app.use cors()
  setUpText "static path"
  app.use(express.static(root.resolve('dist'), { maxAge: 30 * 60 * 60 * 24 * 1000 }))
  setUpText "methods override"
  app.use override()
  setUpText "cookie parser"
  app.use cookieParser()
  setUpText "body parser"
  app.use bodyParser.json()

  if config.isDev()
    setUpText 'morgan'
    morgan = require 'morgan'
    { Writable } = require 'stream'
    # use stream to use logger instead of console
    stream = new Writable
      write: (data, encoding, cb) ->
        logger.info data
        return cb()
    app.use morgan("dev", { stream })


initSession = (app) ->
  app.use session
    saveUninitialized: true,
    resave: false,
    secret: config.sessionSecret
    store: new MongoStore({
      mongooseConnection: db
      collection: config.sessions.collection
      autoReconnect: true
      autoRemove: 'interval',
      autoRemoveInterval: 10
    })
    cookie: config.sessions.cookie
    name: config.sessions.name
  setUpText "session with mongo"


initHelmetHeaders = (app) ->
  setUpText "helmet header"
  app.use helmet()
  app.use helmet.xssFilter()
  app.use helmet.noSniff()
  app.use helmet.frameguard()
  app.use helmet.ieNoOpen()
  app.use crossdomain()
  app.use helmet.hidePoweredBy()


initAuth = (app) ->
  setUpText "passport"
  passport app


# create our express app
app = express()
app.set "port", config.port
app.set 'service', 'the server'
app.locals.year = moment().format("YYYY")
app.locals.app =
  name: pkg.name
  version: pkg.version
  description: pkg.description
app.locals.root = root.path

# Set up our express app
initMiddleware(app)
initSession(app)
initHelmetHeaders(app)
initAuth(app)

# register routes
require('../routes')(app)

# handle errors
app.use (err, req, res, next) ->
  logger.error err
  if err.status and err.status != 500
    {status} = err
    delete err.status
    return res.status(status).json(err)
  return res.sendStatus(500)

module.exports = app