'use strict';
const {
    remote,
    ipcRenderer
} = require('electron');
const BrowserWindow = remote.BrowserWindow;
const Config = require('../../config.js');
const setMenu = require('./tray.set.js')(remote);

const blink = (enabled) => {
    if (enabled === undefined) {
        enabled = true;
    }
    ipcRenderer.send('tray-blink', enabled);
};

const setTitle = (title) => {
    let appTray = BrowserWindow.tray;
    appTray.setTitle(title);
};

module.exports = {
    setMenu,
    blink,
    setTitle
};