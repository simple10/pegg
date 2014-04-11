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
        <a href="#home">Home</a>
        <a href="#questions/new">Create Question</a>
        <Login />
      </div>
    `

module.exports = TopNav
