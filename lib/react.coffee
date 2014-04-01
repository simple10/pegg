# Modularize React to make it available in React developer tools
# https://github.com/facebook/react-devtools

React = require('../node_modules/react/addons')

# Make available for React developer tools
window.React = React

module.exports = React
