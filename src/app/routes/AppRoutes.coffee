Parse = require 'Parse'
NavActions = require 'actions/NavActions'
SingleCardActions = require 'actions/SingleCardActions'
UserActions = require 'actions/UserActions'

#define router class
AppRouter = Parse.Router.extend(
  routes:
    "login": "login"
    "play": "play"
    "activity": "activity"
    "create": "create"
    "settings": "settings"
    "profile": "profile"
    "card/:card/:peggee": "card"
    "activity/:card/:peggee": "activity"
    ":code": "auth"

  login: ->
#    NavActions.loadPage "login"

  card: (card, peggee) ->
    if card? and peggee?
      NavActions.loadLink card, peggee
      SingleCardActions.load card, peggee, 'card'

  activity: (card, peggee) ->
    if card? and peggee?
      NavActions.loadLink card, peggee
      SingleCardActions.load card, peggee, 'activity'

  decks: ->
    #NavActions.selectMenuItem "decks"

  auth: (code) ->
    UserActions.auth code
)

appRoutes = new AppRouter()

Parse.history.start()

# Use pushState in production
# TODO: get webpack-dev-server to rewrite URLs to always serve index.html
#Parse.history.start
#   pushState: true

