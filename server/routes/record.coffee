handler          = require 'express-async-handler'
moment           = require 'moment'

{Record}         = require '../model'
{APIRoute}       = require './router'
{http, validate} = require '../util'

module.exports = (app) ->

  app.get APIRoute.record.base(), handler (req, res) ->
    {page, size, date} = req.query
    size = parseInt(size) || 20
    skip = (parseInt(page - 1) || 0) * size
    query = {}
    if date
      date = moment(date)
      throw http.BAD_REQUEST 'Bad date' if not date.isValid()
      query.receivedAt = date
    records = await Record.find(query).skip(skip).limit(size)
    return res.json records.map (record) -> record.toHypermediaObject()

  app.post APIRoute.record.base(), validate({
    receivedAt:   { type: Date,   required: true }
    npi:          { type: String, required: true }
    taxID:        { type: String, required: true }
    providerName: { type: String, required: true }
    name:         { type: String, required: true }
    email:        { type: String, required: true }
    phone:        { type: String, required: true }
  }), handler (req, res) ->
    record = new Record(req.body)
    record = await record.save()
    return res.json record.toHypermediaObject()

  app.get APIRoute.record.detail(), handler (req, res) ->
    record = await Record.findById(req.params.id)
    throw http.NOT_FOUND() if not record
    return res.json record.toHypermediaObject()

  app.put APIRoute.record.status(), validate({
    status: { required: true, type: String }
  }), handler (req, res) ->
    {id} = req.params
    {status} = req.body
    record = await Record.findById(id)
    throw http.NOT_FOUND() if not record
    throw http.BAD_REQUEST() if record.status in ['approved', 'rejected']
    return res.json record.toHypermediaObject() if record.status == status
    record.status = status
    result = await record.save()
    return res.json result.toHypermediaObject()

  app.get APIRoute.file.base(), (req, res) ->
    {page, size} = req.query
    size = parseInt(size) || 20
    skip = (parseInt(page - 1) || 0) * size
    records = await File.find().skip(skip).limit(size)
    return res.json records.map (record) -> record.toHypermediaObject()