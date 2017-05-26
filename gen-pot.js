var path = require('path');
var Module = require('module');
var _ = require('underscore');
var gettextParser = require('gettext-parser');
var fs = require('fs');
var vm = require('vm');

global._ = _;
_.mixin(require('underscore.deepclone'));

if (process.env['NODE_PATH']) {
  process.env['NODE_PATH'] += ':' + path.resolve('./bower_components');
} else {
  process.env['NODE_PATH'] = path.resolve('./bower_components');
}
Module._initPaths();
module.paths.unshift(path.resolve('./bower_components'));
global.window = global;
var jsdom = require('jsdom');
var window = jsdom.jsdom().defaultView;
global.jQuery = global.$ = require('./bower_components/jquery/dist/jquery.js')(window);
global.document = window.document;
global.rivets = require('./bower_components/rivets/dist/rivets.js');
global.Backbone = require('./bower_components/backbone/backbone.js');
global.Backbone.DeepModel = require('backbone-deep-model');

// Disable the interpolation to catch up all of the patterns
_.templateSettings = {
  interpolate: null
};
global.Formbuilder = require('./formbuilder.js');

var rf = {
  get: (() => '')
};

_.each(Formbuilder.fields, function(v, k) {
  var el;
  el = $(v.view({rf: rf}));
  rivets.bind(el, {model: rf}, {prefix: '(?:data\-)?rv'});
  el = $(v.edit({rf: rf}));
  rivets.bind(el, {model: rf}, {prefix: '(?:data\-)?rv'});
  el = $(v.addButton);
  rivets.bind(el, {model: rf}, {prefix: '(?:data\-)?rv'});
});
// dummy to avoid an exception.
// no need to ensure if it works as is
// because fields objects were already parsed the above.
Formbuilder.fields[''] = {
  edit: (() => undefined),
  view: (() => undefined)
};

_.each(Formbuilder.templates, function(v, k) {
  var el;
  el = $(v({rf: rf,
            editStructure: true,
            commonCheckboxes: true,
            repeatable: true,
            repeating: true,
            fieldsEnabled: Formbuilder.inputFields,
            fieldsEnabledNonInput: Formbuilder.nonInputFields,
            datasources: []
           }));
  rivets.bind(el, {model: rf}, {prefix: '(?:data\-)?rv'});
});

// Generate POT
var translations = {'': {'': {msgid: '', comments: {flag: 'fuzzy'}}}};

_.each(Formbuilder.languageTable_['en'], function(v, k) {
  var msg = {msgctxt: '', msgstr: null, msgid: k, comments: {}};
  translations[''][k] = msg;
});
var data = {charset: 'utf-8',
            headers: {
              'project-id-version': 'PACKAGE VERSION',
              'language-team': 'LANGUAGE <LL@li.org>',
              'po-revision-date': 'YEAR-MO-DA HO:MI+ZONE',
              'language': '',
              'mime-version': '1.0',
              'content-type': 'text/plain; charset=UTF-8',
              'content-transfer-encoding': '8bit',
              'pot-creation-date': new Date().toISOString().replace('T', ' ').replace(/:\d{2}.\d{3}Z/, '+0000'),
              'plural-forms': ''
            },
            translations: translations
           };
var pot = gettextParser.po.compile(data);
var ofile = path.join(path.dirname(process.argv[1]), 'po', 'formbuilder.pot');

process.stdout.write('Writing ' + ofile + ' ... ');
fs.writeFile(ofile, pot, (e) => {
  if (e) {
    process.stdout.write('FAILED\n');
    console.error(e);
  } else {
    process.stdout.write('DONE\n');
  }
});
