###*
@jsx React.DOM
###

React = require 'react'

Layout = React.createClass
  render: ->
    @transferPropsTo `
      <div>
        <div className="container">
          <div className="content">
            {this.props.children}
          </div>
        </div>
      </div>
    `

module.exports = Layout
