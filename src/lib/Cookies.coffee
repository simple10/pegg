# From https://developer.mozilla.org/en-US/docs/Web/API/document.cookie
#
# :: cookies.coffee ::
#
# A complete cookies reader/writer framework with full unicode support.
#
# Revision #1 - September 4, 2014
#
# https://developer.mozilla.org/en-US/docs/Web/API/document.cookie
#
# This framework is released under the GNU Public License, version 3 or later.
# http://www.gnu.org/licenses/gpl-3.0-standalone.html
#
# Syntaxes:
#
# * docCookies.setItem(name, value[, end[, path[, domain[, secure]]]])
# * docCookies.getItem(name)
# * docCookies.removeItem(name[, path[, domain]])
# * docCookies.hasItem(name)
# * docCookies.keys()

Cookies =
  getItem: (sKey) ->
    return null  unless sKey
    decodeURIComponent(document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) or null

  setItem: (sKey, sValue, vEnd, sPath, sDomain, bSecure) ->
    return false  if not sKey or /^(?:expires|max\-age|path|domain|secure)$/i.test(sKey)
    sExpires = ""
    if vEnd
      switch vEnd.constructor
        when Number
          sExpires = (if vEnd is Infinity then "; expires=Fri, 31 Dec 9999 23:59:59 GMT" else "; max-age=" + vEnd)
        when String
          sExpires = "; expires=" + vEnd
        when Date
          sExpires = "; expires=" + vEnd.toUTCString()
    document.cookie = encodeURIComponent(sKey) + "=" + encodeURIComponent(sValue) + sExpires + ((if sDomain then "; domain=" + sDomain else "")) + ((if sPath then "; path=" + sPath else "")) + ((if bSecure then "; secure" else ""))
    true

  removeItem: (sKey, sPath, sDomain) ->
    return false  unless @hasItem(sKey)
    document.cookie = encodeURIComponent(sKey) + "=; expires=Thu, 01 Jan 1970 00:00:00 GMT" + ((if sDomain then "; domain=" + sDomain else "")) + ((if sPath then "; path=" + sPath else ""))
    true

  hasItem: (sKey) ->
    return false  unless sKey
    (new RegExp("(?:^|;\\s*)" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=")).test document.cookie

  keys: ->
    aKeys = document.cookie.replace(/((?:^|\s*;)[^\=]+)(?=;|$)|^\s*|\s*(?:\=[^;]*)?(?:\1|$)/g, "").split(/\s*(?:\=[^;]*)?;\s*/)
    nLen = aKeys.length
    nIdx = 0

    while nIdx < nLen
      aKeys[nIdx] = decodeURIComponent(aKeys[nIdx])
      nIdx++
    aKeys

module.exports = Cookies
