    Client = require('raven').Client

    module.exports = new Client process.env.SENTRY_DNS
    module.exports.parseRequest = (req, kwargs = {}) ->
      kwargs.http =
        method: req.method
        query: req.query
        headers: req.headers
        data: req.body
        url: req.originalUrl

      kwargs

    if process.env.NODE_ENV isnt 'development'
      module.exports.patchGlobal (id, err) ->
        console.error 'Uncaught Exception'
        console.error err.message
        console.error err.stack
        process.exit 1

