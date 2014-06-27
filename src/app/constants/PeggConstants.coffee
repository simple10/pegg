Utils = require 'Utils'

module.exports =
  actions: Utils.keyMirror
    MENU_SELECT: null
    PEGGBOX_FETCH: null
    SET_LOAD: null
    PEGG_SUBMIT: null
    PREF_SUBMIT: null
    CARD_RATE: null
    CARD_PASS: null
    CARD_COMMENT: null
    USER_LOGIN: null
    USER_LOGOUT: null
    SUBSCRIBER_SUBMIT: null
    PLAY_CONTINUE: null

  stores: Utils.keyMirror
    # Generic
    CHANGE: null

    # Specific
    CARD_RATED: null
    UNLOCK_ACHIEVED: null
    PLAY_SAVED: null
    SUBSCRIBE_PASS: null
    SUBSCRIBE_FAIL: null
    COMMENTS_FETCHED: null
    CARDS_LOADED: null
    PLAY_CONTINUED: null
    LOAD_ERROR: null
    NO_PREFS_REMAINING: null
    NO_PEGGS_REMAINING: null
    PREFS_LOADED: null
    PEGGS_LOADED: null
