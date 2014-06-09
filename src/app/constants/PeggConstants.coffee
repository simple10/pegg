Utils = require 'Utils'

module.exports =
  actions: Utils.keyMirror
    MENU_SELECT: null
    PEGGBOX_FETCH: null
    GAME_FETCH: null
    CARD_ANSWER: null
    RATE_CARD: null

  stores: Utils.keyMirror
    CHANGE: null
    CREATE: null
    DELETE: null
    ANSWERED: null
    RATED: null
