// https://github.com/petehunt/reacthack-core/blob/master/lib/ReactHack.js
// https://github.com/petehunt/reacthack-core/blob/master/browser-index.js
// Combined ReactHack.js and browser-index
// Added container as param to ReactHack.start
// Moved handleRouteChange function inside start function to make container available

var React = require('react');
var Parse = require('parse');
var FetchingMixin = require('FetchingMixin');


var router = null;

// Make React available in the global scope for dev tools to work correctly
// https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi

// TODO: use pushState for everything.

var ReactHack = {
  start: function(container, routes, pushState) {
    if (router) {
      throw new Error('Already started ReactHack');
    }

    var idseed = 0;
    var backboneRoutes = {};
    var backboneMethods = {};


    function handleRouteChange(component) {
      var routeParams = Array.prototype.slice.call(arguments, 1);
      React.renderComponent(
        component({routeParams: routeParams}, null),
        container
      );
    }

    for (var route in routes) {
      if (!routes.hasOwnProperty(route)) {
        continue;
      }

      var routeComponentClass = routes[route];
      var routeName = 'route' + (idseed++);

      backboneRoutes[route] = routeName;
      backboneMethods[routeName] = handleRouteChange.bind(this, routeComponentClass);
    }

    // Set up default (error) route
    backboneRoutes['*default'] = 'fourohfour';
    backboneMethods['fourohfour'] = function() {
      React.renderComponent(React.DOM.h1(null, 'ReactHack route not found.'), container);
    };

    backboneMethods.routes = backboneRoutes;

    var AppRouter = Parse.Router.extend(backboneMethods);
    router = new AppRouter();
    Parse.history.start({pushState: !!pushState});
  }
};

ReactHack.FetchingMixin = FetchingMixin;

module.exports = ReactHack;
