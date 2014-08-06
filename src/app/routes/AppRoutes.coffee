Parse = require 'Parse'
NavActions = require 'actions/NavActions'

#define router class
AppRouter = Parse.Router.extend(
  routes:
    "login": "login"
    "play": "play"

  login: ->
    #NavActions.selectMenuItem "login"

  play: ->
    #NavActions.selectMenuItem "play"

  decks: ->
    #NavActions.selectMenuItem "decks"
)

appRoutes = new AppRouter()

Parse.history.start()

# Use pushState in production
# TODO: get webpack-dev-server to rewrite URLs to always serve index.html
# Parse.history.start
#   pushState: true

