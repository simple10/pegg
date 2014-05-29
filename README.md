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

For BDD, simply run `gulp test` and write failing tests first and
then get them to pass by writing the code. The test task automatically
runs a development server. No other commands are needed.

To run the development server directly without tests, use one of the
following commands.

```bash
# Run webpack-dev-server
gulp serve

# Run dev server and open browser
gulp serve --open

# Or manually run webpack to see what it's doing behind the scenes.
# Typically, you would just inspect code in the browser debugger
# instead of calling webpack directly.
webpack -d --colors

```

Gulp is used instead of grunt to manage build tasks.
Gulp is easier to configure and faster due to streaming IO instead of writing files to disk.

Webpack is used instead of browserify to compile assets and manage JavaScript dependencies.
Webpack can handle CSS and other file types besides JavaScript. This allows for views to be
completely self contained with CSS, fonts, and JavaScript dependencies declared at the top
of the view file.

## Style Guides

* [AirBnB](https://github.com/airbnb/javascript)



# Testing

**Run test environment:**
```
# Install karma-cli globally
npm install -g karma-cli

# Run tests and watch for changes; tests are automatically rerun
gulp test

# Run tests once
gulp test --once
```

pegg uses mocha for BDD style tests.

See  [behavior driven development primer](http://msdn.microsoft.com/en-us/magazine/gg490346.aspx).

BDD is an evolution of TDD where tests are first written from an acceptance
perspective rather than from a code testing perspective. Rather than thinking
about what the inside of a function does and writing a test, the developer just
needs to think about what she wants the function to return and test for that.
This approach allows for tests to be written before code and generally promotes
an easier refactoring cycle.

Most frontend/client/browser testing strategies rely on either running tests
directly in the browser or running against a simulated environment like node.js
with jsdom. pegg officially supports running tests in the browser with karma
without the need for mocking famo.us or other core components.

Mocha is also configured to run directly from the command line. However,
this is not recommended for pegg front-end testing since it would require
significant mocking of core dependencies like famo.us.

pegg uses webpack to transpile CoffeeScript and provide `require` in
the browser which is freaking awesome. However, webpack introduces a bit of
complexity

**GOTCHA:** tests need to change number of lines in order to not be served a
cached version by webpack. If a test is changed but the results appear to be
incorrect, try adding or removing blank lines to the test file and saving it
to trigger cache busting.

## Utils in use
* [Mocha](http://visionmedia.github.io/mocha/) – BDD/TDD test framework
* [Karma](http://karma-runner.github.io/0.12/index.html) – test runner
* [Chai](http://chaijs.com/) – assertion library
* [Sinon.js](http://sinonjs.org/) – spies, stubs and mocks
* [Sinon-Chai](https://github.com/domenic/sinon-chai)

## Utils of interest
* [WD.js](https://github.com/admc/wd)
* [CasperJS](http://casperjs.org/)
* [PhantomCSS](https://github.com/Huddle/PhantomCSS)
* [Jest](http://facebook.github.io/jest/)
* [Chai as Promised](https://github.com/domenic/chai-as-promised/) – add async support to chai
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

```bash
# Compile assets for production
gulp build
```

The package.json and bower.json files should be updated to use specific versions to ensure
consistency between development and production.

Does npm have the equivalent of Bundler's Gemfile.lock???



# Resources

## General
* https://github.com/ericclemmons/genesis-skeleton
* https://github.com/Famous/famous
* https://github.com/Famous/examples

## 3D
* [CSS 3D Matrix Transformations](http://www.eleqtriq.com/2010/05/css-3d-matrix-transformations/)

## Testing
* [Testing and Debugging Angular](http://www.yearofmoo.com/2013/09/advanced-testing-and-debugging-in-angularjs.html)

## Streams
* [Stream Handbook](https://github.com/substack/stream-handbook)
* [este.js](https://github.com/steida/este) – isomorphic web dev framework
* https://www.youtube.com/watch?v=lQAV3bPOYHo


## Webpack
* [The Front-end Tooling Book](http://tooling.github.io/book-of-modern-frontend-tooling/dependency-management/webpack/getting-started.html)

## gulp
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




