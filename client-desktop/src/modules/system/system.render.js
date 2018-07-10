const {
    ipcRenderer,
    remote
} = require('electron');
const mac = require('getmac')
const configInfo = require('../../config.js');

var macAddress = null
mac.getMac(function(err, mac) {
    if (err) throw err
    macAddress = mac;
})

var _exports = {
    getDeviceId: () => {
        return macAddress;
    },
    getPlatform: () => {
        return process.platform;
    },
    clearCache: function() {
        ipcRenderer.send('clear-cache');
    },
    dbPath: remote.app.getPath('userData'),
    version: configInfo.PACKAGE.VERSION,
    userDataPath: remote.app.getPath('userData'),
    setConnectStatus: function(isConnect) {
        ipcRenderer.send('set-connect', isConnect);
    }
}

ipcRenderer.on('logError', (event, msg) => {
    console.error('main process error:', msg)
})

module.exports = _exports;
