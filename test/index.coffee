app = require '../src/server'
mongo = require '../src/mongo'

before (done) ->
  @timeout 10000
  mongo.on 'ready', done

describe 'API v1', ->
  require './routes/api_v1-spec'

