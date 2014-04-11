###*
@jsx React.DOM
###

React = require 'react'

Avatar = React.createClass
  render: ->
    @transferPropsTo `
      <img src={this.props.src} class="avatar" />
    `

module.exports = Avatar
