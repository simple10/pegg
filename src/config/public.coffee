# Public config vars and tokens.
# This file is committed to git and available to the client.

DEFAULT_ENV = 'dev'

env_config =
  dev:
    parse:
      jsKey: 'APlTN2pD4nis5r3DYMfblkDk9fknMYplkqYafXNm'
      appId: 'zogf8qxK4ULBBRBn2EhYWwddyUczTDks9w56mNsr'
  production:
    parse:
      jsKey: 'APlTN2pD4nis5r3DYMfblkDk9fknMYplkqYafXNm'
      appId: 'zogf8qxK4ULBBRBn2EhYWwddyUczTDks9w56mNsr'

config =
  # Parse client credentials
  parse: env_config[process.env.NODE_ENV or DEFAULT_ENV].parse

  facebook:
    appId: '1410524409215955'
    redirectUrl: 'http://www.pegg.us'
    expirationDays: 30

  aviary:
    apiKey: 'cdef40f2d4f076a2'

  filepicker:
    apiKey: 'A36NnDQaISmXZ8IOmKGEQz'

module.exports = config
