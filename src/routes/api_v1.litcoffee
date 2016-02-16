    express = require 'express'
    geoutil = require 'geoutil'
    mongo   = require '../mongo'

    apiv1 = express.Router()

    apiv1.get '/', (req, res) ->
      res.json
        boundary_intersect_post:
          method: 'POST'
          endpoint: "#{req.originalUrl}/boundary/intersect/"
          example_body: '{"geojson": { "type": "LineString", "coordinates": […] }}'
        line_analyze_post:
          method: 'POST'
          endpoint: "#{req.originalUrl}/boundary/intersect/"
          example_body: '{"geojson": { "type": "LineString", "coordinates": […] }}'
        gpx_parse_post:
          method: 'POST'
          endpoint: "#{req.originalUrl}/gpx/parse/"
          example_body: 'multipart/form-data upload'

    apiv1.post '/boundary/intersect', (req, res, next) ->
      if not req.body.geojson
        return res.status(400).json message: 'Body should be a JSON object'

      if req.body.geojson.type not in ['Point', 'LineString', 'Polygon']
        return res.status(422).json
          message: 'Geometry type must be Point, Linestring, or Polygon'

      if not (req.body.geojson.coordinates instanceof Array)
        return res.status(422).json message: 'Geometry coordinates must be an Array'

      query = geojson: $geoIntersects: $geometry: req.body.geojson

      mongo.grenser.find(query, {fields: geojson: 0}).toArray (err, docs) ->
        return next err if err

        typer = Område: 'områder', Fylke: 'fylker', Kommune: 'kommuner'
        ret = områder: [], fylker: [], kommuner: []

        for doc in docs when typer[doc.type] isnt undefined
          if doc.type is 'Område'
            ret[typer[doc.type]].push _id: doc._id, navn: doc.navn
          else
            ret[typer[doc.type]].push doc.navn

        return res.json ret

    apiv1.post '/line/analyze', (req, res, next) ->
      if not req.body.geojson
        return res.status(400).json message: 'Body should be a JSON object'

      if req.body.geojson.type not in ['Point', 'LineString', 'Polygon']
        return res.status(422).json
          message: 'Geometry type must be Point, Linestring, or Polygon'

      if not (req.body.geojson.coordinates instanceof Array)
        return res.status(422).json message: 'Geometry coordinates must be an Array'

      geojson = req.body.geojson

      geojson.properties ?= {}
      geojson.properties.start = type: 'Point', coordinates: geojson.coordinates[0]
      geojson.properties.stop  =
        type: 'Point'
        coordinates: geojson.coordinates[geojson.coordinates.length-1]

      return res.json
        length: Math.floor geoutil.lineDistance req.body.geojson.coordinates, true
        geojson: geojson

    apiv1.use '/gpx/parse', require('multer')
      putSingleFilesInArray: true
      dest: require('os').tmpdir()

    readFileSync = require('fs').readFileSync
    DOMParser = require('xmldom').DOMParser
    domparser = new DOMParser()
    geojsonFromGpx = require('togeojson').gpx

    apiv1.post '/gpx/parse', (req, res, next) ->
      res.end() if not req.files

      for field, files of req.files
        for file, i in files
          req.files[field][i] =
            fieldname: file.fieldname
            filename: file.originalname
            extension: file.extension
            mimetype: file.mimetype
            geojson: null

          if file.extension is 'gpx'
            dom = domparser.parseFromString readFileSync file.path, 'utf8'
            req.files[field][i].geojson = geojsonFromGpx dom
          else
            req.files[field][i].error = "Invalid extension '#{file.extension}'"

      res.json req.files

    module.exports = apiv1

