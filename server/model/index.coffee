mongoose = require 'mongoose'
config   = require '../config'


mongoose.Promise = global.Promise
{server, options} = config.db

# Connect to mongoDB
mongoose.connect server, options
mongoose.connection.on 'error', (err) ->
  throw new Error(err) if err

mongoose.connection.once 'open', () ->
  console.log "Connected to #{server}"

# Exports all db access objects
modelCache = {}
model = (name) ->
  Object.defineProperty module.exports, name,
    get: () ->
      modelCache[name] ?= mongoose.model(name, require("./#{name.toLowerCase()}"))
      return modelCache[name]

model(dao) for dao in [
  'File'
  'Record'
]

# objectId function
module.exports.generateObjectId = mongoose.Types.ObjectId
module.exports.isObjectId = mongoose.isValidObjectId