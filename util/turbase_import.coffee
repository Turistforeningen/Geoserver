mongo = require '../src/mongo'
async = require 'async'
request = require 'request'
dashdash = require 'dashdash'

ObjectID = require('mongodb').ObjectID

readFileSync = require('fs').readFileSync

options = [
  names: ['help', 'h']
  type: 'bool'
  help: 'Print this help and exit.'
,
  names: ['key', 'k']
  type: 'string'
  help: 'Turbase API key'
  helpArg: 'API_KEY'
]

parser = dashdash.createParser options: options

try
  opts = parser.parse process.argv
catch e
  console.error 'turbase_import.coffee: error: %s', e.message
  process.exit 1

if opts.help or not opts.key
  help = parser.help({includeEnv: true}).trimRight()

  console.log 'usage: coffee turbase_import.coffee --key API_KEY [OPTIONS]\n'
  #console.log 'This tool will let you import counties and municpalities from'
  #console.log 'Kartvket to you MongoDB database. Input data must be original'
  #console.log 'GeoJSON files obtained form Kartverket. No warranties given.\n'
  console.log 'options:\n' + help

  process.exit 0

requestOpts =
  uri: 'http://api.nasjonalturbase.no/områder'
  json: true
  qs:
    api_key: opts.key
    tilbyder: 'DNT'
    status: 'Offentlig'
    geojson: ''
    fields: ['navn', 'geojson'].join ','
    limit: 50
    skip: 0

mongo.once 'ready', ->
  grenser = mongo.db.collection 'grenser'

  total = count = 0
  async.doWhilst (cb) ->
    requestOpts.qs.skip = count

    request requestOpts, (e, r, body) ->
      total = body.total
      count += body.count

      console.log 'total', total
      console.log 'count', count

      async.eachLimit body.documents, 5, (doc, cb) ->
        doc._id = new ObjectID doc._id
        doc.type = 'Område'
        console.log "Updating #{doc.navn} (#{doc._id})..."
        grenser.replaceOne _id: doc._id, doc, upsert: true, cb
      , cb

  , ->
    count < total
  , (err) ->
    mongo.db.close()
    console.log 'done'
    throw err if err
    process.exit 0

