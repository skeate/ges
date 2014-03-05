# GES

The Gaia Enhancement Suite is a set of modules designed to improve the
experience of using the site [Gaia Online](http://www.gaiaonline.com).
Some modules include Quick Quote, Thread Filter, and Account Switcher.

## Users

The extension can be found on the [Chrome Web Store][cws]. Install from there.
Chrome should handle updating automatically.

[cws]:https://chrome.google.com/webstore/detail/mgcnknfohcgfckjaebhijnpgdmngoceg

## Developers

### Requirements

Only major requirement to build GES is [node](http://nodejs.org/); once
you have that, you can also run

    npm install -g grunt bower

[Grunt](http://gruntjs.com/) is a task runner used to run tests & build,
and [bower](http://bower.io/) is a package manager for the front end.

### Installation

Once you have those two installed, go to the directory where you cloned this
repo and run

    npm install

This will install all the required packages, and also run `bower install` to
get jQuery &c.

To get it into Chrome, open your Extensions, turn on Developer Mode, click
"Load unpacked extension...", and point it to the folder where manifest.json
resides (./chrome/app/).

### Build

To be honest, there's probably not much reason to build, since it just
packages everything into a .zip to upload to the Chrome Web Store. If you want
to anyway, run `grunt build`.

### Test

`grunt test`. Also, `grunt jshint` will validate any .js files. Also also,
`grunt` by itself will run `jshint`, `test`, and `build`.

### Contributing

Fork this repo, make changes, send pull request. Please also contribute tests.

Literate Coffeescript preferred.

## License

GPL v3
