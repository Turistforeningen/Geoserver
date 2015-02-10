Geoserver
=========

I house geoserver written in Node.JS.

## API

### Boundaries

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

## [MIT Licensed](https://github.com/Turistforeningen/node-vagrant-template/blob/master/LICENSE)

