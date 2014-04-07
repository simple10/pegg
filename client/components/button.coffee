###*
@jsx React.DOM
###

React = require 'react'

Button = React.createClass
  getDefaultProps: ->
    href: 'javascript:;'

  render: ->
    @transferPropsTo `
      <a role="button" className="btn">{this.props.children}</a>
    `

module.exports = Button
