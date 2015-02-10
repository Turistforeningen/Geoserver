assert  = require 'assert'
request = require 'supertest'

app     = require '../src/server'
mongo   = require '../src/mongo'

req = request app

before (done) ->
  @timeout 10000
  mongo.on 'ready', done

describe 'CORS', ->
  it 'should send CORS headers', (done) ->
    req.options '/'
      .set 'Origin', 'http://example.com'
      .expect 200
      .expect 'Access-Control-Allow-Origin', 'http://example.com'
      .expect 'Access-Control-Allow-Methods', 'GET, POST'
      .expect 'Access-Control-Allow-Headers', 'X-Requested-With, Content-Type'
      .expect 'Access-Control-Expose-Headers', 'X-Response-Time'
      .expect 'Access-Control-Allow-Max-Age', 0
      .end done

  it 'should deny non-allowed Origin', (done) ->
    req.options '/'
      .set 'Origin', 'http://foo.com'
      .expect 403
      .end done

describe 'API v1', ->
  require './routes/api_v1-spec'

