# ContentSelect

[![Build Status](https://travis-ci.org/GetmeUK/ContentSelect.svg?branch=master)](https://travis-ci.org/GetmeUK/ContentSelect)

> A JavaScript library providing cross-browser support for content selection.

## Building
To build the library you'll need to use Grunt. First install the required node modules ([grunt-cli](http://gruntjs.com/getting-started) must be installed):
```
git clone https://github.com/GetmeUK/ContentSelect.git
cd ContentSelect
npm install
```

Then run `grunt build` to build the project.

## Testing
To test the library you'll need to use Jasmine. First install Jasmine:
```
git clone https://github.com/pivotal/jasmine.git
mkdir ContentSelect/jasmine
mv jasmine/dist/jasmine-standalone-2.0.3.zip ContentSelect/jasmine
cd ContentSelect/jasmine
unzip jasmine-standalone-2.0.3.zip
```

Then open `ContentSelect/SpecRunner.html` in a browser to run the tests.

Alternatively you can use `grunt jasmine` to run the tests from the command line.

## Documentation
Full documentation is available at http://getcontenttools.com/api/content-select

## Browser support
- Chrome
- Firefox
- IE9+
