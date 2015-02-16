assert  = require 'assert'
request = require 'supertest'

app     = require '../../src/server'
mongo   = require '../../src/mongo'
trail   = require '../assets/trail.json'

req = request app
base = '/api/v1'

describe '/', ->
  it 'should do return API documentation', (done) ->
    req.get "#{base}"
      .expect 200
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

describe '/line/analyze', ->
  url = "#{base}/line/analyze"

  it 'should return 400 for invalid body', (done) ->
    req.post url
      .expect 400
      .end done

  it 'should return 422 for invalid geometry type', (done) ->
    req.post url
      .send geojson: type: 'Foo'
      .expect 422
      .end done

  it 'should return 422 for invalid geometry coordinates', (done) ->
    req.post url
      .send geojson: type: 'LineString', coordinates: 'Foobar'
      .expect 422
      .end done

  it 'should return for simple LineString', (done) ->
    req.post url
      .send geojson: type: 'LineString', coordinates: [
        [ 5.32907, 60.39826 ]
        [ 6.41474, 60.62869 ]
      ]
      .expect 200
      .expect (res) ->
        assert.deepEqual res.body,
          length: 64781
          geojson:
            type: 'LineString'
            coordinates: [ [ 5.32907, 60.39826 ], [ 6.41474, 60.62869 ] ]
            properties:
              start: type: 'Point', coordinates: [ 5.32907, 60.39826 ]
              stop: type: 'Point', coordinates: [ 6.41474, 60.62869 ]
      .end done

