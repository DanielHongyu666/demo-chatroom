const {
    remote,
} = require('electron');
const path = require('path');
const configInfo = remote.require('./config.js')

let _setImmediate = setImmediate;

process.once('loaded', function() {
  global.setImmediate = _setImmediate;
});

const isArray = (arr) => {
    return Object.prototype.toString.call(arr) === '[object Array]';
};
const isString = (str) => {
    return Object.prototype.toString.call(str) === '[object String]';
};

// desktop.require 报错
const requireError = {
    type: () => {
        console.error('RongDesktop require error, name must string');
    },
    module: (name) => {
        console.error('Invalid module: ', name);
    }
};

let RongDesktop = {
    require: (name) => {
        if (RongDesktop[name]) {
            return RongDesktop[name];
        }
        if (!isString(name)) {
            requireError.type();
        }
        let uri = RongDesktop.Modules[name];
        if (!uri) {
            requireError.module(name);
        }
        RongDesktop[name] = require(uri);
        return RongDesktop[name];
    }
};

RongDesktop.Modules = {
    Window: '../modules/window/window.render.js',
    App: '../modules/app/app.render.js',
    Tray: '../modules/tray/tray.render.js',
    Dock: '../modules/dock/dock.js',
    DB: '../modules/database/database.js',
    Emoji: '../modules/emoji/emoji.js',
    Shortcut: '../modules/shortcut/shortcut.js',
    Logger: '../modules/logger/logger.js',
    Network: '../modules/network/network.js',
    Download: '../modules/download_extra/download.render.js',
    DownloadChunk: '../modules/download_extra/download_chunk.render.js',
    Screenshot: '../modules/screenshot/screenshot.render',
    System: '../modules/system/system.render.js',
    RemoteControl: `../modules/remote_control/${process.platform}/remote_control.render.js`,
    IMLib: '../modules/ronglib/ronglib.render'
};


Object.assign(RongDesktop, {
    configInfo: configInfo,
    remote: remote
});

window.RongDesktop = RongDesktop;