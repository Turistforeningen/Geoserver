Geoserver
=========

[![Build status](https://img.shields.io/wercker/ci/55218d2a6dda5c9817000dc0.svg "Build status")](https://app.wercker.com/project/bykey/412cde1d2e74f111f5b80af62ddbc7d0)
[![Dependency status](https://img.shields.io/david/Turistforeningen/Geoserver.svg "Dependency status")](https://david-dm.org/Turistforeningen/Geoserver)

In-house Geoserver written in Node.JS.

## API

### Boundary

#### Intersect

**Methods:** `POST`
**Endpoint:** `/api/v1/boundary/intersect`

Get boundaries that intersect with a given geometry structure. Or in other words
return POLYGONS that a given geometry is a part of / inside of.

```bash
curl -X POST \
  -H "Content-Type: Application/Json" \
  -d '{"geojson": { "type": "LineString", "coordinates": [[ 5.32907, 60.39826 ], [ 6.41474, 60.62869 ]] }}' \
  "/api/v1/boundary/intersect"
```

Has the corresponding output of:

```json
{
  "områder": [
    { "_id": "52408144e7926dcf1500004b", "navn": "Stølsheimen, Bergsdalen og Vossefjellene" },
    { "_id": "52408144e7926dcf15000025", "navn": "Byfjellene i Bergen" },
    { "_id": "52408144e7926dcf15000035", "navn": "Nordhordland" }
  ],
  "fylker": [
    "Hordaland"
  ],
  "kommuner": [
    "Samnanger",
    "Vaksdal",
    "Osterøy",
    "Bergen",
    "Voss"
  ]
}
```

### Line

#### Analyze

**Methods:** `POST`
**Endpoint:** `/api/v1/line/analyze`

Analyze a LineString and return some interesting properties.

```bash
curl -X POST \
  -H "Content-Type: Application/Json" \
  -d '{"geojson": { "type": "LineString", "coordinates": [[ 5.32907, 60.39826 ], [ 6.41474, 60.62869 ]] }}' \
  "/api/v1/line/analyze"
```

Has the corresponding output of:

```json
{
  "length": 64781,
  "geojson": {
    "type": "LineString",
    "coordinates": [[ 5.32907, 60.39826 ], [ 6.41474, 60.62869 ]],
    "properties": {
      "start": { "type": "Point", "coordinates": [ 5.32907, 60.39826 ] },
      "stop": { "type": "Point", "coordinates": [ 6.41474, 60.62869 ] }
    }
  }
}
```
## [MIT Licensed](https://github.com/Turistforeningen/node-vagrant-template/blob/master/LICENSE)

