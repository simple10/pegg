###*
@jsx React.DOM
###

React = require 'react'
TopNav = require 'components/topnav'
Button = require 'components/button'

Layout = React.createClass
  render: ->
    @transferPropsTo `
      <div>
        <TopNav />
        <div className="container">
          <div className="content">
            {this.props.children}
          </div>
        </div>
      </div>
    `

module.exports = Layout
