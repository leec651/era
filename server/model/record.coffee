mongoose = require 'mongoose'
moment   = require 'moment'
Schema   = mongoose.Schema
_        = require 'lodash'


STATUS = [
  'pending'
  'errored'
  'approved' # terminal state
  'rejected' # terminal state
]

schema =
  receivedAt: Date
  npi: String
  taxId: String
  providerName: String
  name: String
  email: String
  phone: String
  assignee: String
  tinInn: Boolean
  oonEnrollmentRecieved: Boolean
  hasActiveOrg: Boolean
  hasAch: Boolean
  eraStatus: String
  billingNpi: String
  notes: String
  notified: Boolean
  status:
    type: String
    required: true
    default: 'pending'
    enum: STATUS
  fileId:
    type: Schema.Types.ObjectId
    ref: 'Record'
    required: true
  note: String
  createdAt:
    required: true
    type: Date
    default: Date.now
  deletedAt: Date
  updatedAt:
    required: true
    type: Date
    default: Date.now

RecordSchema = new Schema(schema)

RecordSchema.pre 'save', (next) ->
  this.receivedAt = moment(this.receivedAt || new Date()).startOf('day').toDate()
  return next()

RecordSchema.methods.toHypermediaObject = () ->
  obj = this.toObject()
  delete obj.__v
  return obj

RecordSchema.index {status: 1, receivedAt: 1, deletedAt: -1}

module.exports = RecordSchema
module.exports.recordSchema = schema