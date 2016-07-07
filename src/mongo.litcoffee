    EventEmitter = require('events').EventEmitter
    MongoClient = require('mongodb').MongoClient
    inherits = require('util').inherits

    Mongo = (uri) ->
      EventEmitter.call @

      new MongoClient.connect uri, (err, database) =>
        console.log('MongoDB connection opened')

        throw err if err
        @db = database
        @grenser = @db.collection 'grenser'

        @emit 'ready'

      @

    inherits Mongo, EventEmitter

    module.exports = new Mongo(process.env.MONGO_URI)
