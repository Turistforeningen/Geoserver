    express = require 'express'
    logger  = require 'morgan'
    body    = require 'body-parser'
    raven   = require 'raven'
    url     = require 'url'

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

    app.use body.json()

    if app.get 'env' isnt 'TEST'
      app.use logger 'dev'
      app.use librato.middleware
      app.use librato.count name: 'request', period: 1

## COORS

    origins = process.env.ALLOW_ORIGINS?.split(',') or []

    app.use (req, res, next) ->
      if req.get 'Origin'
        origin = url.parse req.get('Origin') or ''

        if origin.hostname not in origins
          error = new Error "Bad Origin Header #{req.get('Origin')}"
          error.status = 403
          return next error

        res.set 'Access-Control-Allow-Origin', req.get('Origin')
        res.set 'Access-Control-Allow-Methods', 'GET, POST'
        res.set 'Access-Control-Allow-Headers', 'X-Requested-With, Content-Type'
        res.set 'Access-Control-Expose-Headers', 'X-Response-Time'
        res.set 'Access-Control-Allow-Max-Age', 0

      return res.status(200).end() if req.method is 'OPTIONS'
      return next()

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

      console.log err if app.get 'env' isnt 'TEST'

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

