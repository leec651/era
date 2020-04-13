APIRoute =
  record:
    base: -> "/api/record"
    detail: (id=":id") -> "/api/record/#{id}"
    status: (id=":id") -> "/api/record/#{id}/status"
  file:
    base: -> '/api/file'
    detail: (id=":id") -> "/api/file/#{id}"

url = (path, port=2000) ->
  # TODO: prod vs dev
  return "http://localhost:#{port}#{path}"

module.exports = { APIRoute, url }