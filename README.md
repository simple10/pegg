# Pegg Famous

Pegg is a social mobile game where users ask and answer questions about each other.

It's also our first app built on the Famo.us platform and the Parse BaaS.


# Install

```bash
git clone https://github.com/auggernaut/pegg.git
cd pegg
npm install -g gulp
npm install -g webpack-dev-server bower
npm install
```

# Development

```bash
# Run webpack-dev-server
gulp serve

# Or manually run webpack if needed
webpack -d --colors
```

# Production

```bash
# Compile assets for production
gulp build
```


# Development Overview

Gulp is used instead of grunt to manage development tasks.
Gulp is easier to configure and faster due to streaming IO instead of writing files to disk.

Webpack is used instead of browserify to compile assets and manage JavaScript dependencies.
Webpack can handle CSS and other file types besides JavaScript. This allows for views to be
completely self contained with CSS, fonts, and JavaScript dependencies declared at the top
of the view file.

Gulp could be dropped since it's mostly just passing through to webpack. But gulp has a lot
of useful plugins and example tasks that could be useful later on.


## Style Guides

* [AirBnB](https://github.com/airbnb/javascript)


# Testing

## CURRENT STATUS:

* `karma start karma.conf.js` is functional
* `gulp [mocha|karma]` is WIP
* `gulp mocha` is working in coffeescript-seed-project (not pushed); need to port to pegg
* GOTCHA: tests need to change number of lines in order to not be served a cached version


* [Mocha](http://visionmedia.github.io/mocha/)
* [Karma](http://karma-runner.github.io/0.12/index.html)
* [WD.js](https://github.com/admc/wd)
* [CasperJS](http://casperjs.org/)
* [PhantomCSS](https://github.com/Huddle/PhantomCSS)
* [Jest](http://facebook.github.io/jest/)
* [Chai](http://chaijs.com/) – assertion library
* [Sinon.js](http://sinonjs.org/) – spies, stubs and mocks
* [Chai as Promised](https://github.com/domenic/chai-as-promised/)
* [Sinon-Chai](https://github.com/domenic/sinon-chai)
* [Rewire](https://github.com/jhnns/rewire)


# Directory Structure

* **/app**: all javascript client-side app code, i.e collections, models, views, widgets
* **/config**: config vars and initializers
* **/css**: styles
* **/lib**: client-side libraries
* **/spec**: tests


# Dependencies

With webpack, each JavaScript file must explicitly require its dependencies.

By convention, each view should have a corresponding CSS file in of the same name in /styles.
The CSS files should be explicitly required by the view vs assuming the CSS is already loaded.

Any changes to explicity required files will be automatically picked up by webpack and updated
in development. Files @imported in sass will not be automatically recompiled with the current
webpack configuration. Any changes to app.scss or _settings.scss requires a restart of the
development server.


# NPM vs Bower

Use Bower for any dependencies that are only used in the browser. Use npm for everything else.



# Production

The package.json and bower.json files should be updated to use specific versions to ensure
consistency between development and production.

Does npm have the equivalent of Bundler's Gemfile.lock?


## Deploy

```bash
# build production assets
gulp build
```

Rest of deploy details TBD.


# Sources

## Of Interest:

* https://github.com/ericclemmons/genesis-skeleton
* https://github.com/Famous/famous
* https://github.com/Famous/examples


# Resources

3D
* [CSS 3D Matrix Transformations](http://www.eleqtriq.com/2010/05/css-3d-matrix-transformations/)

* [Testing and Debugging Angular](http://www.yearofmoo.com/2013/09/advanced-testing-and-debugging-in-angularjs.html)

Streams
* [Stream Handbook](https://github.com/substack/stream-handbook)
* [este.js](https://github.com/steida/este) – isomorphic web dev framework
* https://www.youtube.com/watch?v=lQAV3bPOYHo


Webpack
* [The Front-end Tooling Book](http://tooling.github.io/book-of-modern-frontend-tooling/dependency-management/webpack/getting-started.html)

gulp
* [gulp Recipes](https://github.com/gulpjs/gulp/tree/master/docs/recipes)
* [gulp Plugins](http://gratimax.github.io/search-gulp-plugins/)

# Notes

Parse 1.2.18 and earlier has a bug with Facebook login. Facebook returns valid iso8601 dates for
the token expires field but Parse._parseDate fails to parse it correctly and break login. Fucking great.
A temp patch has been added to parse-1.2.18-fixed-parsedate.js. If the regex fails, the date is parsed
using the browser's native date parser. This will only work in ECMAScript 5 browser.

A permanent solution is to fix the regex.

See Taasky demo code for the best example of how to create forms and integrate with Backbone Model.

The docs on famo.us are pretty useless. Better to just read the code and comments.




