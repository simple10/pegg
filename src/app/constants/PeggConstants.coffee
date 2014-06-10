Utils = require 'Utils'

module.exports =
  actions: Utils.keyMirror
    MENU_SELECT: null
    PEGGBOX_FETCH: null
    GAME_FETCH: null
    CARD_ANSWER: null
    CARD_RATE: null
    CARD_PICK: null

  stores: Utils.keyMirror
    # Generic
    CHANGE: null

    # Specific ... probably make these more explicity
    # e.g. CARD_ANSWERED
    CARD_ANSWERED: null
    CARD_RATED: null
