'use strict'
const {
    app,
    BrowserWindow,
    ipcMain,
    session
} = require('electron');
const platform = require('../../utils').platform
const Config = require('../../config')
const path = require('path')

// 配置是否需要清除缓存; windows 需要在窗体都关闭后做清除,否则出错
var needDelCache = false;

ipcMain.on('clear-cache', () => {
    needDelCache = true;
})

ipcMain.on('purge-cache', () => {
    clearCache();
})

ipcMain.on('set-connect', (event, isConnect) => {
    setConnectStatus(isConnect);
})

app.on('window-all-closed', () => {
    if(needDelCache){
        clearCache();
    }
})

var loadHome = () => {
    BrowserWindow.mainWindow && BrowserWindow.mainWindow.reload()
}

var clearCache = () => {
    if (!BrowserWindow.mainWindow) return
    const ses = session.defaultSession
    new Promise(rslv => ses.clearCache(() => rslv()))
    .then(() => new Promise(rslv => ses.clearStorageData(() => rslv())))
    .then(() => loadHome())
}

var setConnectStatus = (isConnect) => {
    if (platform.win32) {
        var icon = isConnect ? Config.WIN.TRAY : Config.WIN.TRAY_DROP;
        var iconPath = path.join(__dirname, '../../../res', icon);
        BrowserWindow.tray.setImage(iconPath);
    }
}