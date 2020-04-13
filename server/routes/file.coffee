handler          = require 'express-async-handler'
async            = require 'async'
moment           = require 'moment'
formidable       = require 'formidable'
hl               = require 'highland'
csv              = require 'csv-parse'
fs               = require 'fs'
_                = require 'lodash'

{File, Record}   = require '../model'
{APIRoute}       = require './router'
{http, validate} = require '../util'


# csv header definition
HEADERS = [
  'receivedAt'
  'assignee'
  'npi'
  'taxId'
  'providerName'
  'name'
  'email'
  'phone'
  'tinInn'
  'oonEnrollmentRecieved'
  'hasActiveOrg'
  'hasAch'
  'eraStatus'
  'billingNpi'
  'status'
  'notes'
  'notified'
]

getStatus = (value) ->
  value = _.toLower value
  return switch
    when value in ['in progress', 'to do']  then 'pending'
    when value in ['reject', 'rejected']    then 'rejected'
    when value in ['approved']              then 'approved'
    else 'pending'


toBoolean = (value) ->
  value = _.toLower(value)
  return switch
    when value in ['yes', 'true', true]        then true
    when value in ['no', 'false', true, 'n/a'] then false

clean = (row) ->
  row                       = _.mapValues row, (value) -> return value if !!value
  row.status                = getStatus row.status
  row.phone                 = _.replace row.phone, '-', ''
  row.tinInn                = toBoolean row.tinInn
  row.notified              = toBoolean row.notified
  row.oonEnrollmentRecieved = toBoolean row.oonEnrollmentRecieved
  row.hasActiveOrg          = toBoolean row.hasActiveOrg
  row.hasAch                = toBoolean row.hasAch
  return row

module.exports = (app) ->

  app.get APIRoute.file.base(), handler (req, res) ->
    {page, size} = req.query
    size = parseInt(size) || 20
    skip = (parseInt(page - 1) || 0) * size
    files = await File.find().skip(skip).limit(size).lean(true)
    return res.json files.map (file) -> item.toHypermediaObject()

  app.post APIRoute.file.base(), handler (req, res) ->
    form = formidable({ multiples: true })
    form.parse req , handler (err, fields, files) ->
      if err
        console.error err
        return res.sendStatus(500)
      if not files.eraDelta
        error = {error: {message: 'ERA file must be provided'}}
        console.error error
        return res.status(400).json(error)
      if files.eraDelta.type != 'text/csv'
        error = {error: {message: 'ERA file must be a csv file'}}
        console.error error
        return res.status(400).json(error)

      # Save file as processing
      file = new File(files.eraDelta)
      file.save (err) ->
        if err
          console.error err
          return res.sendStatus(500)

        # set up csv parser
        csvParser = csv
          skip_empty_lines: true
          columns: HEADERS
          from: 2

        # set up worker for async csv parsing
        result = { totalRows: 0, erroredRows: [] }
        executor = hl.wrapCallback (row, done) ->
          result.totalRows++
          row = clean(row)
          row.fileId = file._id
          record = new Record(clean(row))
          record.save (error) ->
            if error
              result.erroredRows.push { row, error }
            return done()

        # process csv
        stream = fs.createReadStream(files.eraDelta.path, 'utf8').pipe(csvParser)
        hl(stream)
          .map(executor)
          .parallel(50)
          .stopOnError (err) ->
            if err
              console.error err
              return res.sendStatus(500)
          .done (err) ->
            if err
              console.error err
              return res.sendStatus(500)
            # todo mark file as complete
            file.status = 'processed'
            file.totalRows = result.totalRows
            file.erroredRows = result.erroredRows
            file.save (err) ->
              if err
                console.error err
                return res.sendStatus(500)
              return res.json
                file: file.toHypermediaObject()
                result: result