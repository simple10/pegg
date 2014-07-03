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
    PREF_SAVED: null
    SUBSCRIBE_PASS: null
    SUBSCRIBE_FAIL: null
    LOAD_ERROR: null
    NO_PREFS_REMAINING: null
    NO_PEGGS_REMAINING: null
    PLAY_PREFS: null
    PLAY_PEGGS: null
    CARDS_CHANGE: null
    CHOICES_CHANGE: null
    COMMENTS_CHANGE: null
    PLAY_CHANGE: null
    CARD_WIN: null
    CARD_FAIL: null
