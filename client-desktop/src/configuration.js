'use strict';
const {app} = require('electron');

function getUserHome() {
  // return process.env[(process.platform === 'win32') ? 'USERPROFILE' : 'HOME'];
  return app.getPath('userData');
}

const fs = require('fs')
const nconf = require('nconf')

const configPath = `${getUserHome()}/setting_rong.json`;
var config;
try {
    config = nconf.file({
      file: configPath,
    });
} catch(exception) {
    fs.unlinkSync(configPath);
    config = nconf.file({
      file: configPath,
    });
}

function saveSettings(settingKey, settingValue) {
  config.set(settingKey, settingValue);
  config.save();
}

function readSettings(settingKey) {
  config.load();
  return config.get(settingKey);
}

module.exports = {
  saveSettings,
  readSettings,
};
