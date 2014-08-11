# Public config vars and tokens.
# This file is committed to git and available to the client.

DEFAULT_ENV = 'dev'

env_config =
  dev:
    parse:
      jsKey: 'oBVGtJcA1YL8qAHtRHE1sm46edv3CdxSDCCBAyH3'
      appId: 'jOzfgxXTgD83QGnSyEcJgdCGEE4tNQz2bMEP4Zxe'
  production:
    parse:
      jsKey: 'oBVGtJcA1YL8qAHtRHE1sm46edv3CdxSDCCBAyH3'
      appId: 'jOzfgxXTgD83QGnSyEcJgdCGEE4tNQz2bMEP4Zxe'

config =
  # Parse client credentials
  parse: env_config[process.env.NODE_ENV or DEFAULT_ENV].parse

  facebook:
    appId: '1410524409215955'

  aviary:
    apiKey: 'cdef40f2d4f076a2'

  filepicker:
    apiKey: 'A36NnDQaISmXZ8IOmKGEQz'

module.exports = config
