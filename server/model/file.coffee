mongoose = require 'mongoose'
Schema   = mongoose.Schema
_        = require 'lodash'

STATUS = [
  'processing'
  'processed'
  'errored'
]

schema =
  name: String
  createdAt:
    type: Date
    default: Date.now
    required: true
  status:
    type: String
    default: 'processing'
    required: true
    enum: STATUS
  deletedAt: Date
  updatedAt:
    type: Date
    default: Date.now
    required: true
  size:
    type: String
    required: true
  type:
    type: String
    required: true
  totalRows:
    type: Number
    default: 0
    required: true
  erroredRows:
    type: [Object]
    default: []
    required: true

FileSchema = new Schema(schema)

FileSchema.methods.toHypermediaObject = () ->
  obj = this.toObject()
  delete obj.__v
  return obj

FileSchema.index {name: 1, deletedAt: -1}
FileSchema.index {phone: 1, deletedAt: -1}

module.exports = FileSchema
module.exports.fileSchema = schema