###*
@jsx React.DOM
###

React = require 'react'
window.Parse = Parse = require 'parse'
Button = require 'components/button'

LoginButton = React.createClass
  getInitialState: ->
    loggedIn: @isLoggedIn()

  isLoggedIn: ->
    !!Parse.User.current()

  handleAuthClick: ->
    if @state.loggedIn
      Parse.User.logOut()
      @setState loggedIn: false
    else
      Parse.FacebookUtils.logIn null,
        success: (user) =>
          @setState loggedIn: true
          unless user.existed()
            consol.log 'User signed up and logged in through Facebook!'
          else
            console.log 'User logged in through Facebook!'
        error: (user, error) =>
          @setState loggedIn: false
          Parse.User.logOut()

  render: ->
    @transferPropsTo `
      <div>
        <Button onClick={this.handleAuthClick}>{this.isLoggedIn() ? "Logout" : "Login"}</Button>
      </div>
    `

module.exports = LoginButton
