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
    "card/:card": "card"
    "card/:card/:peggee": "card"
    ":code": "auth"

  login: ->
#    NavActions.loadPage "login"

  card: (card, peggee) ->
    if card?
      NavActions.selectSingleCardItem card, peggee

  activity: () ->
    NavActions.selectMenuItem 'activity'

  profile: () ->
    NavActions.selectMenuItem 'profile'

  settings: () ->
    NavActions.selectMenuItem 'settings'

  create: () ->
    NavActions.selectMenuItem 'create'

  play: () ->
    NavActions.selectMenuItem 'play'

  auth: (code) ->
    UserActions.auth code
)

appRoutes = new AppRouter()

Parse.history.start()

# Use pushState in production
# TODO: get webpack-dev-server to rewrite URLs to always serve index.html
#Parse.history.start
#   pushState: true

