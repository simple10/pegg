# Public config vars and tokens.
# This file is committed to git and available to the client.

DEFAULT_ENV = 'dev'

env_config =
  dev:
    parse:
      jsKey: 'WGkL8be69NuEmYdY3kt6yhihK1wcmmmSWtixexAc'
      appId: 'tR8QqYHsxTCrfuBwZKlBEVgrOcvGBQYoLkrxy0LK'
  production:
    parse:
      jsKey: 'XrA5EweJyzPmhxQZY6DqE8qotDmAk13s5JKhkyql'
      appId: 'sMSeqS1EP23z0vo3TgZKd38MBiP9qzrvnv0OHMk8'

config =
  # Parse client credentials
  parse: env_config[process.env.NODE_ENV or DEFAULT_ENV].parse

  facebook:
    appId: '1410524409215955'

  aviary:
    apiKey: 'cdef40f2d4f076a2'

module.exports = config
