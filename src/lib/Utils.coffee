Timer = require 'famous/utilities/Timer'
Transform = require 'famous/core/Transform'

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

module.exports = Utils
