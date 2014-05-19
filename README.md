# Famous

See Taasky demo code for the best example of how to create forms and integrate with Backbone Model.

Also see Famous/examples on github.

The docs on famo.us are pretty useless. Better to just read the code and comments.



# Install

```bash
git clone https://github.com/auggernaut/pegg.git
cd pegg
npm install -g webpack-dev-server bower
npm install
```

# Development

```bash
# Run webpack-dev-server
gulp

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


# Testing

* [Jasmine](http://jasmine.github.io/)
* [Karma](http://karma-runner.github.io/0.12/index.html)
* [CasperJS](http://casperjs.org/)
* [PhantomCSS](https://github.com/Huddle/PhantomCSS)
* [Jest](http://facebook.github.io/jest/)

Use [jasmine-npm](https://github.com/pivotal/jasmine-npm) once it's available.
[Minijasminenode](https://github.com/juliemr/minijasminenode/issues/9) will eventually be deprecated.


# Directory Structure

* **/bin**: startup and task scripts
* **/client**: all code and assets for display and interaction; javascript, html, images, css, etc.
* **/config**: config vars and initializers
* **/lib**: shared code that doesn't obviously belong in client or server
* **/server**: all server-side and api code


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
* https://github.com/neebz/backbone-parse


# Resources

* [CSS 3D Matrix Transformations](http://www.eleqtriq.com/2010/05/css-3d-matrix-transformations/)
* [Testing and Debugging Angular](http://www.yearofmoo.com/2013/09/advanced-testing-and-debugging-in-angularjs.html)

# Notes

Parse 1.2.18 and earlier has a bug with Facebook login. Facebook returns valid iso8601 dates for
the token expires field but Parse._parseDate fails to parse it correctly and break login. Fucking great.
A temp patch has been added to parse-1.2.18-fixed-parsedate.js. If the regex fails, the date is parsed
using the browser's native date parser. This will only work in ECMAScript 5 browser.

A permanent solution is to fix the regex.






