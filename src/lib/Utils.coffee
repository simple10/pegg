Timer = require 'famous/src/utilities/Timer'
Transform = require 'famous/src/core/Transform'

Utils =
  # Creates enumeration with keys equal to values.
  keyMirror: (obj) ->
    ret = {}
    for key of obj
      ret[key] = key  if obj.hasOwnProperty key
    ret

  animateAll: (mod, states) ->
    for state in states
      Timer.after ((mod, state)->
        if state.origin?
          mod.setOrigin state.origin, state.transition
        if state.align?
          mod.setAlign state.align, state.transition
        if state.scale?
          mod.setTransform Transform.scale(state.scale...), state.transition
        if state.transform?
          mod.setTransform state.transform, state.transition
        if state.opacity?
          mod.setOpacity state.opacity, state.transition
      ).bind(@, mod, state), state.delay

  animate: (mod, state, callback) ->
    if !callback then callback = (->)
    Timer.after (->
      if state.origin?
        mod.setOrigin state.origin, state.transition, callback
      if state.align?
        mod.setAlign state.align, state.transition, callback
      if state.scale?
        mod.setTransform Transform.scale(state.scale...), state.transition, callback
      if state.transform?
        mod.setTransform state.transform, state.transition, callback
      if state.opacity?
        mod.setOpacity state.opacity, state.transition, callback
    ), state.delay

  getViewportWidth: () ->
    # console.log 'getViewportWidth', document.documentElement.clientWidth, window.innerWidth
    Math.max document.documentElement.clientWidth, window.innerWidth || 0

  getViewportHeight: () ->
    # console.log 'getViewportHeight', document.documentElement.clientHeight, window.innerHeight
    Math.max document.documentElement.clientHeight, window.innerHeight || 0

  getContentWidth: () ->
    @getViewportWidth() - 20

  getAjax: (endpoint, params, cb) ->
    #http://stackoverflow.com/questions/8567114/how-to-make-an-ajax-call-without-jquery
    url = "#{endpoint}?#{params}"
    req = new XMLHttpRequest()

    req.addEventListener 'readystatechange', ->
     if req.readyState is 4                        # ReadyState Complete
       successResultCodes = [200, 304]
       if req.status in successResultCodes
#         data = eval '(' + req.responseText + ')'
         cb req.responseText
       else
         cb 'Error loading data...'

    req.open 'GET', url, false
    req.send()

  parseQueryString: (queryString, name) ->
    #https://gist.github.com/greystate/1274961
    variables = queryString.split '&'
    pairs = ([key, value] = pair.split '=' for pair in variables)
    if name?
      for [key, value] in pairs
        return value if key is name
    else
      return pairs

module.exports = Utils


Date::addDays = (days) ->
  dat = new Date(@valueOf())
  dat.setDate dat.getDate() + days
  dat
