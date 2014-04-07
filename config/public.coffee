# Public config vars and tokens.
# This file is committed to git and available to the client.

module.exports =
  # Parse client credentials
  parse:
    appId: '08asqa4QvUyNIDTIl3BS70CLcKJGoh2mI1MXwJEf'
    jsKey: 'G19GjSAlnMOvTjcDqE6KxxKHsMnygHmbsfDYg8gm'

  facebook:
    appId: '1410524409215955'

  # 3rd party authentication server
  gatekeeper:
    server: 'http://localhost:9999'

  # Image upload server
  upload:
    server: 'http://localhost:9998'
    s3bucket: 'http://pegg.s3.amazonaws.com'
