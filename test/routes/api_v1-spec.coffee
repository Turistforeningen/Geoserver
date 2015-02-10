assert  = require 'assert'
app     = require '../../src/server'
mongo   = require '../../src/mongo'
request = require 'supertest'

trail   = require '../assets/trail.json'

req = request app
base = '/api/v1'

describe '/', ->
  it 'should do this', (done) ->
    req.get "#{base}/"
      .expect 200
      .expect (res) ->
        assert.deepEqual res.body,
          boundary_intersect_post:
            method: 'POST'
            endpoint: '/api/v1//boundary/intersect/'
            example_body: '{"geojson": { "type": "LineString", "coordinates": [[ 5.32907, 60.39826 ], [ 6.41474, 60.62869 ]] }}'
      .end done

describe '/boundary/intersect', ->
  it 'should return 400 for invalid body', (done) ->
    req.post "#{base}/boundary/intersect"
      .expect 400
      .end done

  it 'should return 422 for invalid geometry type', (done) ->
    req.post "#{base}/boundary/intersect"
      .send geojson: type: 'Foo'
      .expect 422
      .end done

  it 'should return 422 for invalid geometry coordinates', (done) ->
    req.post "#{base}/boundary/intersect"
      .send geojson: type: 'LineString', coordinates: 'Foobar'
      .expect 422
      .end done

  it 'should return for simple LineString', (done) ->
    req.post "#{base}/boundary/intersect"
      .send geojson: type: 'LineString', coordinates: [
        [ 5.32907, 60.39826 ]
        [ 6.41474, 60.62869 ]
      ]
      .expect 200
      .expect (res) ->
        #assert.deepEqual res.body.områder, []
        assert.deepEqual res.body.kommuner, [ 'Samnanger', 'Vaksdal', 'Osterøy', 'Bergen', 'Voss' ]
        assert.deepEqual res.body.fylker, [ 'Hordaland' ]
      .end done

  it 'should return for complex LineString', (done) ->
    @timeout 10000

    req.post "#{base}/boundary/intersect"
      .send trail
      .expect 200
      .expect (res) ->
        #assert.deepEqual res.body.områder, []
        assert.deepEqual res.body.kommuner, [ 'Vang', 'Lærdal', 'Aurland', 'Hol', 'Ål', 'Ulvik' ]
        assert.deepEqual res.body.fylker, [ 'Oppland', 'Buskerud', 'Sogn og Fjordane', 'Hordaland' ]
      .end done

