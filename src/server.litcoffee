    express = require 'express'
    logger  = require 'morgan'
    body    = require 'body-parser'
    raven   = require 'raven'

    mongo   = require './mongo'
    sentry  = require './sentry'
    librato =
      middleware: require('./librato').middleware.use
      count     : require('./librato').middleware.routeCount
      flush     : require('./librato').flush

## Configuration

    process.env.PORT ?= 8080
    process.env.LIBRATO_INTERVAL ?= 1

    app = module.exports = express()

    app.set 'json spaces', 2
    app.set 'x-powered-by', false

    app.use logger 'dev' if app.get 'env' isnt 'TEST'
    app.use body.json()
    app.use librato.middleware
    app.use librato.count name: 'request', period: 1

## Routes

    app.get '/', (req, res, next) ->
      res.redirect '/api/v1'

    app.use '/api/v1', require './routes/api_v1'

### Error Handling

Before handling the error ours self make sure that it is propperly logged in
Sentry by using the express/connect middleware.

    app.use raven.middleware.express sentry

All errors passed to `next` or exceptions ends up here. We set the status code
to `500` if it is not already defined in the `Error` object. We then print the
error mesage and stack trace to the console for debug purposes.

Before returning a response to the user the request method is check. HEAD
requests shall not contain any body – this applies for errors as well.

    app.use (err, req, res, next) ->
      res.status err.status or 500

      console.log err

      if res.statusCode >= 500
        console.error err.message
        console.error err.stack

      return res.end() if req.method is 'HEAD'
      return res.json message: err.message or 'Unknown error'

### Start Server

    if not module.parent
      mongo.on 'ready', ->
        app.listen process.env.PORT
        console.log "Server is listening on port #{process.env.PORT}"

