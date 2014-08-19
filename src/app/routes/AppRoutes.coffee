Parse = require 'Parse'
NavActions = require 'actions/NavActions'
ReviewActions = require 'actions/ReviewActions'

#define router class
AppRouter = Parse.Router.extend(
  routes:
    "login": "login"
    "play": "play"
    "card/:card/:peggee": "card"
    "activity/:card/:peggee": "activity"

  login: ->
#    NavActions.loadPage "login"

  card: (card, peggee) ->
    if card? and peggee?
      NavActions.loadLink card, peggee
      ReviewActions.load card, peggee, 'card'

  activity: (card, peggee) ->
    if card? and peggee?
      NavActions.loadLink card, peggee
      ReviewActions.load card, peggee, 'activity'

  decks: ->
    #NavActions.selectMenuItem "decks"
)

appRoutes = new AppRouter()

Parse.history.start()

# Use pushState in production
# TODO: get webpack-dev-server to rewrite URLs to always serve index.html
#Parse.history.start
#   pushState: true

