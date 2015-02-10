    express = require 'express'
    mongo   = require '../mongo'

    apiv1 = express.Router()

    apiv1.get '/', (req, res) ->
      res.json
        intersect_url: "#{req.originalUrl}/boundary/intersect/"

    apiv1.post '/boundary/intersect', (req, res, next) ->
      if not req.body.geometry
        return res.status(400).json message: 'Body should be a JSON object'

      if req.body.geometry.type not in ['Point', 'LineString', 'Polygon']
        return res.status(422).json message: 'Geometry type must be Point, Linestring, or Polygon'

      if not (req.body.geometry.coordinates instanceof Array)
        return res.status(422).json message: 'Geometry coordinates must be an Array'

      query = geojson: $geoIntersects: $geometry: req.body.geometry

      mongo.grenser.find(query, {fields: geojson: 0}).toArray (err, docs) ->
        return next err if err
        return res.json docs

    module.exports = apiv1

