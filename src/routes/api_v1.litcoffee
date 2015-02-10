    express = require 'express'
    mongo   = require '../mongo'

    apiv1 = express.Router()

    apiv1.get '/', (req, res) ->
      res.json
        intersect_url: "#{req.originalUrl}/boundary/intersect/"

    apiv1.post '/boundary/intersect', (req, res, next) ->
      if not req.body.geojson
        return res.status(400).json message: 'Body should be a JSON object'

      if req.body.geojson.type not in ['Point', 'LineString', 'Polygon']
        return res.status(422).json message: 'Geometry type must be Point, Linestring, or Polygon'

      if not (req.body.geojson.coordinates instanceof Array)
        return res.status(422).json message: 'Geometry coordinates must be an Array'

      query = geojson: $geoIntersects: $geometry: req.body.geojson

      mongo.grenser.find(query, {fields: geojson: 0}).toArray (err, docs) ->
        return next err if err

        typer = Område: 'områder', Fylke: 'fylker', Kommune: 'kommuner'
        ret = områder: [], fylker: [], kommuner: []

        for doc in docs when typer[doc.type] isnt undefined
          if doc.type is 'Område'
            ret[typer[doc.type]].push doc._id
          else
            ret[typer[doc.type]].push doc.navn

        return res.json ret

    module.exports = apiv1

