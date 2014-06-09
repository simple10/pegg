Utils = require 'Utils'

module.exports =
  actions: Utils.keyMirror
    MENU_SELECT: null
    PEGGBOX_FETCH: null
    GAME_FETCH: null
    CARD_ANSWER: null

  stores: Utils.keyMirror
    CHANGE: null
    CREATE: null
    DELETE: null
    NEXTCARD: null
