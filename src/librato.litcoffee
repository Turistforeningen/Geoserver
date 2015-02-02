    librato = require 'librato-express'

    librato.initialise
      email: process.env.LIBRATO_USER
      token: process.env.LIBRATO_TOKEN
      prefix: 'geoserver.'

    librato.start()

    module.exports = librato

