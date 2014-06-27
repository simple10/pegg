Parse = require 'Parse'
MenuActions = require 'actions/MenuActions'

#define router class
AppRouter = Parse.Router.extend(
  routes:
    "login": "login"

  login: ->
    MenuActions.selectMenuItem "login"
)

appRoutes = new AppRouter()

Parse.history.start()

# Use pushState in production
# TODO: get webpack-dev-server to rewrite URLs to always serve index.html
# Parse.history.start
#   pushState: true

