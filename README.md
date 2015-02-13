Geoserver
=========

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
  "områder": [],
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
  "length": 123520,
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

