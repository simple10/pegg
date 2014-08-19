
require './scss/settings.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
Utils = require 'lib/Utils'
UserStore = require 'stores/UserStore'
NavActions = require 'actions/NavActions'

class SettingsView extends View
  cssPrefix: 'settings'

  constructor: ->
    super
    @init()

  init: ->
    logout = new Surface
      size: [ 200 , 50 ]
      content: 'Logout'
      classes: ["#{@cssPrefix}__logout__button"]
    logoutMod = new StateModifier
      align: [0.5, 0.32]
      origin: [0.5, 0]
    logout.on 'click', ->
      UserStore.logout()
      NavActions.logout()

    @add(logoutMod).add logout


module.exports = SettingsView
