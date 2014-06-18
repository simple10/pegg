Utils = require 'Utils'

module.exports =
  actions: Utils.keyMirror
    MENU_SELECT: null
    PEGGBOX_FETCH: null
    GAME_FETCH: null
    CARD_ANSWER: null
    CARD_RATE: null
    CARD_PICK: null
    USER_LOGIN: null
    USER_LOGOUT: null
    SUBSCRIBER_SUBMIT: null
    PLAY_CONTINUE: null

  stores: Utils.keyMirror
    # Generic
    CHANGE: null

    # Specific ... probably make these more explicit
    # e.g. CARD_ANSWERED
    CARD_ANSWERED: null
    CARD_RATED: null
    UNLOCK_ACHIEVED: null
    PLAY_CONTINUED: null
    SUBSCRIBE_PASS: null
    SUBSCRIBE_FAIL: null
