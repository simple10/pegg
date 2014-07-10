# Public config vars and tokens.
# This file is committed to git and available to the client.

module.exports =
  # Parse client credentials
  parse:
    appId: if process.env.NODE_ENV == 'production' then 'tR8QqYHsxTCrfuBwZKlBEVgrOcvGBQYoLkrxy0LK' else 'sMSeqS1EP23z0vo3TgZKd38MBiP9qzrvnv0OHMk8'
    jsKey: if process.env.NODE_ENV == 'production' then 'WGkL8be69NuEmYdY3kt6yhihK1wcmmmSWtixexAc' else 'XrA5EweJyzPmhxQZY6DqE8qotDmAk13s5JKhkyql'

  facebook:
    appId: '1410524409215955'

  aviary:
    apiKey: 'cdef40f2d4f076a2'
