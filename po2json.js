'use strict';

const fs = require('fs');
const gettextParser = require('gettext-parser');
const path = require('path');
const glob = require('glob');

let podir = path.join(path.dirname(process.argv[1]), 'po');

glob.sync(path.join(podir, '*.po'),
          {nodir: true, dot: false})
  .forEach((v) => {
    process.stdout.write('Processing ' + v + ' ... ');
    let po = fs.readFileSync(v, 'utf-8');
    let data = gettextParser.po.parse(po);
    let json = {};
    let lang, f, ofile;

    if (data && data.headers && data.headers.language) {
      lang = data.headers.language;
    } else if ((f = path.basename(v).match(/^([a-zA-Z]{2,3}(?:_[a-zA-Z]{2,3})?)\.po$/))) {
      lang = f[1];
    } else {
      throw new Error('Unable to guess the targeted language');
    }
    ofile = path.join(podir, '..', 'formbuilder-lang-' + lang + '.json');
    for (let i in data.translations['']) {
      let msg = data.translations[''][i];

      if (!msg.comments || msg.comments.flag == undefined || !msg.comments.flag.match(/fuzzy/)) {
        json[msg.msgid] = msg.msgstr[0];
      }
    }
    fs.writeFile(ofile, JSON.stringify(json), (e) => {
      if (e) {
        process.stdout.write('FAILED\n');
        console.error(e);
      } else {
        process.stdout.write('DONE\n');
      }
    });
  });
