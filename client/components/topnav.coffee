###*
@jsx React.DOM
###

React = require 'react'
Parse = require 'parse'
Button = require 'components/button'

TopNav = React.createClass
  handleAuthClick: ->
    Parse.FacebookUtils.logIn null,
      success: (user) ->
        unless user.existed()
          alert "User signed up and logged in through Facebook!"
        else
          alert "User logged in through Facebook!"
        return
      error: (user, error) ->
        alert "User cancelled the Facebook login or did not fully authorize."
        return

  render: ->
    @transferPropsTo `
      <div>
        <Button onClick={this.handleAuthClick}>Login</Button>
      </div>
    `

module.exports = TopNav
