Parse = require 'Parse'

#define router class
AppRouter = Parse.Router.extend(
  routes:
    "": "home"
    view: "viewImage"

  home: ->
    alert "you are viewing home page"
    return

  viewImage: ->
    alert "you are viewing an image"
    return
)