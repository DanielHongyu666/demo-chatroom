'use strict';
const {
    ipcRenderer,
    remote
} = require('electron');
const current = require('./current.js');
const BrowserWindow = remote.BrowserWindow;
const mark = 'browser_window';
const createMark = `${mark}_create`;
const closeMark = `${mark}_close`;
const closeAllMark = `${mark}_close_all`;

module.exports = {
    create: (option) => {
        ipcRenderer.send(createMark, option);
    },
    send: (type, ...args) => {
        ipcRenderer.send('browser_window_message', type, ...args);
    },
    onReceived: (type, callback) => {
        ipcRenderer.on(type, (evt, ...args) => {
            callback && callback(...args);
        });
    },
    current: current,
    openCacheFolder: function() {
        var path = remote.app.getPath('userData');
        if (remote.shell) {
            remote.shell.showItemInFolder(path);
        }
    },
    // 用于 chrome vue 插件使用
    enableVueDevtool: function(path) {
        const configInfo = require('../../config.js')
        BrowserWindow.addDevToolsExtension(path || configInfo.DEBUGOPTION.VUEPATH);
    }
};