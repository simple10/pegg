###*
@jsx React.DOM
###

# Simple image avatar class.
# Stubbed out for later use with click handlers and default image rendering.

React = require 'react'

Avatar = React.createClass
  render: ->
    @transferPropsTo `<img className="avatar" />`

module.exports = Avatar
