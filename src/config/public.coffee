# Public config vars and tokens.
# This file is committed to git and available to the client.

# Parse client credentials
parse_credentials =
  production:
    jsKey: 'WGkL8be69NuEmYdY3kt6yhihK1wcmmmSWtixexAc'
    appId: 'tR8QqYHsxTCrfuBwZKlBEVgrOcvGBQYoLkrxy0LK'
  dev:
    jsKey: 'XrA5EweJyzPmhxQZY6DqE8qotDmAk13s5JKhkyql'
    appId: 'sMSeqS1EP23z0vo3TgZKd38MBiP9qzrvnv0OHMk8'

config = 
  parse:
    appId: parse_credentials[process.env.NODE_ENV or 'production'].appId
    jsKey: parse_credentials[process.env.NODE_ENV or 'production'].jsKey

  facebook:
    appId: '1410524409215955'

  aviary:
    apiKey: 'cdef40f2d4f076a2'

module.exports = config
