Utils =
  # Creates enumeration with keys equal to values.
  keyMirror: (obj) ->
    ret = {}
    for key of obj
      ret[key] = key  if obj.hasOwnProperty key
    ret

module.exports = Utils
