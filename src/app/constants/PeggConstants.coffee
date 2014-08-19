Utils = require 'Utils'

module.exports =
  actions: Utils.keyMirror
    LOAD_LINK: null
    MENU_SELECT: null
    CARD_SELECT: null
    LOAD_ACTIVITY: null
    LOAD_GAME: null
    LOAD_CARD: null
    LOAD_CATEGORIES: null
    PEGG_SUBMIT: null
    PREF_SUBMIT: null
    PLUG_IMAGE: null
    CARD_RATE: null
    CARD_PASS: null
    CARD_COMMENT: null
    USER_LOGIN: null
    USER_LOGOUT: null
    USER_LOAD: null
    SUBSCRIBER_SUBMIT: null
    PLAY_CONTINUE: null
    ADD_QUESTION: null
    ADD_ANSWERS: null
    ADD_CATEGORIES: null
    NEXT_CARD: null
    PREV_CARD: null
    NEXT_STAGE: null
    PICK_MOOD: null
    FILTER_PREFS: null
    LOGOUT: null
    LOGIN: null

  stores: Utils.keyMirror
    # Generic
    CHANGE: null

    # Specific
    LOGIN_CHANGE: null
    MENU_CHANGE: null
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
    CARD_CHANGE: null
    CHOICES_CHANGE: null
    COMMENTS_CHANGE: null
    PLAY_CHANGE: null
    CARD_WIN: null
    CARD_FAIL: null
    STATUS_CHANGE: null
    ACTIVITY_CHANGE: null
    PLUG_SAVED: null
    PREF_IMAGES_CHANGE: null
    PROFILE_LOAD: null
    CATEGORIES_CHANGE: null
    MOOD_CHANGE: null




