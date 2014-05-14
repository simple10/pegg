# Public config vars and tokens.
# This file is committed to git and available to the client.

module.exports =
  # Parse client credentials
  parse:
    appId: 'sMSeqS1EP23z0vo3TgZKd38MBiP9qzrvnv0OHMk8'
    jsKey: 'XrA5EweJyzPmhxQZY6DqE8qotDmAk13s5JKhkyql'

  facebook:
    appId: '1410524409215955'

  # 3rd party authentication server
  gatekeeper:
    server: 'http://localhost:9999'

  # Image upload server
  upload:
    server: 'http://localhost:9998'
    s3bucket: 'http://pegg.s3.amazonaws.com'

  aviary:
    apiKey: 'cdef40f2d4f076a2'
