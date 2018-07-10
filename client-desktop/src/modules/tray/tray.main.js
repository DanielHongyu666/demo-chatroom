'use strict';
const electron = require('electron');
const {
    BrowserWindow,
    ipcMain,
    app
} = electron;
const Utils = require('../../utils.js');
const platform = Utils.platform;
const Config = require('../../config.js');
const setMenu = require('./tray.set.js')(electron);
const path = require('path');
const baseDir = path.join(__dirname, '../../../res');

const TrayImg =  path.join(baseDir, platform.darwin ? Config.MAC.TRAY : Config.WIN.TRAY);
const TrayOffImg = path.join(baseDir, platform.darwin ? Config.MAC.TRAY_OFF : Config.WIN.TRAY_OFF);

const defaultMenus = () => {
    let mainWindow = BrowserWindow.mainWindow;
    let isTopWin = mainWindow.isAlwaysOnTop();
    let locale = global.locale;
    let template = [
        {
            label: locale.__('winTrayMenus.Open'),
            click () {
                if (mainWindow) {
                    mainWindow.show()
                }
            }
        },
        {
            label: locale.__('winTrayMenus.BringFront'),
            type: 'checkbox',
            checked: isTopWin,
            click () {
                isTopWin = mainWindow.isAlwaysOnTop();
                app.emit('menu.view.bringFront', !isTopWin)
            }
        },
        {
            type: 'separator'
        },
        {
            label: locale.__('winTrayMenus.Exit'),
            click () {
                app.quit();
            }
        }
    ];
    return template;
};

const BlinkHandler = {
    interval: null,
    set: (enabled) => {
        if (enabled) {
            BlinkHandler.start();
        } else {
            BlinkHandler.stop();
        }
    },
    start: () => {
        let flag;
        let iconFile = [ TrayImg, TrayOffImg ];
        BlinkHandler.interval = setInterval(() => {
            flag = !flag;
            // 设置全局 tray 的 icon
            if (BrowserWindow.tray && BrowserWindow.tray.setImage) {
                BrowserWindow.tray.setImage(iconFile[ flag ? 1 : 0 ]);
            }
        }, 500);
    },
    stop: () => {
        clearInterval(BlinkHandler.interval);
        BlinkHandler.interval = null;
        // 设置全局 tray 的 icon
        if (BrowserWindow.tray) {
            BrowserWindow.tray.setImage(TrayImg);
        }
    }
};

ipcMain.on('tray-blink', (event, enabled) => {
    BlinkHandler.set(enabled);
});

module.exports = {
    defaultMenus: defaultMenus(),
    setMenu: setMenu
};