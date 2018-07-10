'use strict';
const {
    app,
    ipcMain
} = require('electron');
const utils = require('../../utils.js');
const Config = require('../../config.js');
const AutoLaunch = require('auto-launch');

/*
获取开机自启实例
 */
const getLauncher = () => {
    let exePath = process.execPath;
    if (utils.platform.darwin) {
        exePath = exePath.split('.app/Content')[0] + '.app';
    }
    return new AutoLaunch({
        name: Config.PACKAGE.APPNAME,
        path: exePath
    });
};

let minecraftAutoLauncher = getLauncher();
// 将 minecraftAutoLauncher 赋值给全局 app, 提供给 app.render.js 使用
app.minecraftAutoLauncher = minecraftAutoLauncher;

/*
设置开机自启
 */
const setAutoLaunch = (isAutoLaunch) => {
    if (isAutoLaunch) {
        return minecraftAutoLauncher.enable();
    }
    minecraftAutoLauncher.disable();
};

ipcMain.on('set-auto-launch', (event, isAutoLaunch) => {
    setAutoLaunch(isAutoLaunch);
});

ipcMain.on('app-relaunch', () => {
    app.exit();
    app.relaunch();
});