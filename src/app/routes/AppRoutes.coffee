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

