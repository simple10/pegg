Parse = require 'Parse'
MenuActions = require 'actions/MenuActions'

#define router class
AppRouter = Parse.Router.extend(
  routes:
    "login": "login"
    "play": "play"

  login: ->
    MenuActions.selectMenuItem "login"

  play: ->
    MenuActions.selectMenuItem "play"

  decks: ->
    MenuActions.selectMenuItem "decks"
)

appRoutes = new AppRouter()

Parse.history.start()

# Use pushState in production
# TODO: get webpack-dev-server to rewrite URLs to always serve index.html
# Parse.history.start
#   pushState: true

