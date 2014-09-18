Utils = require 'Utils'

module.exports =
  actions: Utils.keyMirror
    ADD_ANSWERS: null
    ADD_CATEGORIES: null
    ADD_QUESTION: null
    AUTH: null
    BADGES_VIEWED: null
    CARD_COMMENT: null
    CARD_PASS: null
    CARD_RATE: null
    CARD_SELECT: null
    FILTER_PREFS: null
    LOAD_ACTIVITY: null
    LOAD_CARD: null
    LOAD_CATEGORIES: null
    LOAD_GAME: null
    LOAD_LINK: null
    LOGIN: null
    LOGOUT: null
    MENU_SELECT: null
    NEXT_CARD: null
    NEXT_STAGE: null
    PEGG_SUBMIT: null
    PICK_MOOD: null
    PLAY_CONTINUE: null
    PLUG_IMAGE: null
    PREF_SUBMIT: null
    PREV_CARD: null
    SUBSCRIBER_SUBMIT: null
    USER_LOAD: null
    USER_LOGIN: null
    USER_LOGOUT: null
    SINGLE_CARD_COMMENT: null
    SINGLE_CARD_LOAD: null
    SINGLE_CARD_PEGG: null
    SINGLE_CARD_PREF: null
    SINGLE_CARD_PLUG: null

  stores: Utils.keyMirror
    # Generic
    CHANGE: null

    # Specific
    ACTIVITY_CHANGE: null
    CARDS_CHANGE: null
    CARD_CHANGE: null
    CARD_FAIL: null
    CARD_RATED: null
    CARD_WIN: null
    CATEGORIES_CHANGE: null
    CHOICES_CHANGE: null
    COMMENTS_CHANGE: null
    LOAD_ERROR: null
    LOGIN_CHANGE: null
    MENU_CHANGE: null
    MOOD_CHANGE: null
    NO_PEGGS_REMAINING: null
    NO_PREFS_REMAINING: null
    PLAY_CHANGE: null
    PLAY_PEGGS: null
    PLAY_PREFS: null
    PLUG_SAVED: null
    PREF_IMAGES_CHANGE: null
    PREF_SAVED: null
    PROFILE_ACTIVITY_CHANGE: null
    PROFILE_LOAD: null
    REQUIRE_LOGIN: null
    STATUS_CHANGE: null
    SUBSCRIBE_FAIL: null
    SUBSCRIBE_PASS: null
    UNLOCK_ACHIEVED: null
