mongo = require '../src/mongo'
async = require 'async'
dashdash = require 'dashdash'

readFileSync = require('fs').readFileSync

options = [
  names: ['help', 'h']
  type: 'bool'
  help: 'Print this help and exit.'
,
  names: ['file', 'f']
  type: 'string'
  help: 'File to import.'
  helpArg: 'PATH'
]

parser = dashdash.createParser options: options

try
  opts = parser.parse process.argv
catch e
  console.error 'import.coffee: error: %s', e.message
  process.exit 1

if opts.help or not opts.type or not opts.file
  help = parser.help({includeEnv: true}).trimRight()

  console.log 'usage: coffee import.coffee --file PATH [OPTIONS]'
  console.log '\nThis tool will let you import counties and municpalities from'
  console.log 'Kartvket to you MongoDB database. Input data must be original'
  console.log 'GeoJSON files obtained form Kartverket. No warranties given.\n'
  console.log 'options:\n' + help

  process.exit 0

try
  file = readFileSync opts.file, encoding: 'utf8'
  json = JSON.parse file
catch e
  console.error 'import.coffee: error: %s', e.message
  process.exit 1

docs = []
cache = {}
for feature in json.features
  doc =
    navn: feature.properties.navn
    type: feature.properties.objtype
    nr: feature.properties.fylkesnr or feature.properties.komm
    geojson: feature.geometry
    kilde: 'Kartverket'

  if doc.type is 'Fylker'
    # Ignore duplicates whith invalid GeoJSON
    if doc.geojson.coordinates[0].length < 100
      continue

  if doc.type is 'Kommune'
    remove = []

    # Check for invalid points
    if doc.navn in ['Lund', 'Sokndal']
      for p, i in doc.geojson.coordinates[0]
        remove.push i if p[0] is 6.474612 and p[1] is 58.333559

    # Check for invalid points
    if doc.navn in ['Sørfold', 'Fauske']
      for p, i in doc.geojson.coordinates[0]
        remove.push i if p[0] is 15.588073 and p[1] is 67.331575

    # Remove invalid points
    for i, offset in remove
      doc.geojson.coordinates[0].splice i - offset, 1

  docs.push doc

console.log "Saving #{docs.length} documents to db.."

mongo.once 'ready', ->
  i = 0

  grenser = mongo.db.collection 'grenser'

  async.eachLimit docs, 5, (doc, cb) ->
    console.log ++i
    grenser.replaceOne type: doc.type, nr: doc.nr, doc, upsert: true, cb
  , (err) ->
    mongo.db.close()
    throw err if err

    console.log 'Save success!'

