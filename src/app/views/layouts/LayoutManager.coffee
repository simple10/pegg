Utils = require 'lib/Utils'

# Include Mobile Layout Files
mobile = {
  LoginViewLayout: require 'views/layouts/mobile/LoginViewLayout'
  NewCardViewLayout: require 'views/layouts/mobile/NewCardViewLayout'
  PlayViewLayout: require 'views/layouts/mobile/PlayViewLayout'
  PlayNavViewLayout: require 'views/layouts/mobile/PlayNavViewLayout'
  SignupViewLayout: require 'views/layouts/mobile/SignupViewLayout'
  StatusViewLayout: require 'views/layouts/mobile/StatusViewLayout'
  SingleCardViewLayout: require 'views/layouts/mobile/SingleCardViewLayout'
  CardViewLayout: require 'views/layouts/mobile/CardViewLayout'
}

desktop = {}

tablet = {}

class LayoutsManager
  constructor: (options) ->
    @device = @_getDevice()

  _getDevice: ->
    # TODO return different device type based on viewport size
    width = Utils.getViewportWidth()
    
    'mobile'

  getViewLayout: (viewName) ->
    layout = null

    if @device is 'mobile'
      layout = mobile[viewName + 'Layout']
    else if @device is 'desktop'
      layout = desktop[viewName + 'Layout']
    else if @device is 'tablet'
      layout = tablet[viewName + 'Layout']
    
    layout || {}

module.exports = LayoutsManager
