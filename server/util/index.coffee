_ = require 'lodash'


httpHandler = (status, error={}) ->
  resp = { status }
  if _.isArray(error)
    resp.error = error
  else if _.isObject(error)
    Object.assign resp, error
  else
    resp.message = error
  console.log resp
  return resp

http =
  OK:              httpHandler.bind null, 200
  CREATED:         httpHandler.bind null, 201
  NO_CONTENT:      httpHandler.bind null, 204
  NO_MODIFIED:     httpHandler.bind null, 304
  BAD_REQUEST:     httpHandler.bind null, 400
  UNAUTHORIZED:    httpHandler.bind null, 401
  NOT_FOUND:       httpHandler.bind null, 404
  FORBIDDEN:       httpHandler.bind null, 403
  CONFICT:         httpHandler.bind null, 409
  INTERNAL:        httpHandler.bind null, 500
  GATEWAY_TIMEOUT: httpHandler.bind null, 504

typeValidator = {}
typeValidator[String] = _.isString
typeValidator[Number] = _.isNumber
typeValidator[Array]  = _.isArray
typeValidator[Date]   = _.isDate
typeValidator[Object] = _.isPlainObject

validateHelper = (rules, input) ->
  map = {} # used to make sure there is no recursive object
  errors = []
  for key, {required, type, enums} of rules
    value = input[key]
    if !required
      continue if !value
    else
      if !value
        errors.push
          path: key
          message: "Value is required"
      else
        if !typeValidator[type](value)
          errors.push
            path: key
            message: "[#{key}] must be [#{type.name}]"
        if enums and !(value in enums)
          errors.push
            path: key
            message: "#[#{value}] is not a valid option for field [#{key}]"
  return errors

validate = (rules) ->
  (req, res, next) ->
    for key, {type} of rules
      if !typeValidator[type]
        throw http.INTERNAL()

    for key, value of res.body
      res.body[key] = value.trim()

    errors = validateHelper rules, req.body
    if _.isEmpty errors
      return next()
    else
      throw http.BAD_REQUEST({errors})

module.exports = { validate, http }