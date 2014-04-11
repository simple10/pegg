###*
@jsx React.DOM
###

React = require 'react'
Parse = require 'parse'
Login = require 'components/login'

TopNav = React.createClass
  render: ->
    @transferPropsTo `
      <div>
        <Login />
      </div>
    `

module.exports = TopNav
