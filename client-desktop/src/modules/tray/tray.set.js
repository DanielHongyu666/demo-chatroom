'use strict';
module.exports = (electron) => {
    const {
        Menu,
        Tray,
        BrowserWindow
    } = electron;
    const Utils = require('../../utils.js');
    const platform = Utils.platform;
    const Config = require('../../config.js');
    const path = require('path');
    const baseDir = path.join(__dirname, '../../../res');
    let TrayImg = platform.darwin ? Config.MAC.TRAY : Config.WIN.TRAY;
    TrayImg = path.join(baseDir, TrayImg);

    const formatMenu = (list) => {
        list = list.map((menu) => {
            if (menu.submenus) {
                menu.submenu = menu.submenus
                menu.submenu = formatMenu(menu.submenu);
            }
            return menu;
        });
        return list;
    };

    const setMenu = (option) => {
        if (!option.menus) {
            return;
        }
        let mainWindow = BrowserWindow.mainWindow;
        let appTray = BrowserWindow.tray;
        let tray = appTray || new Tray(TrayImg);
        tray.on('click', () => {
            if (mainWindow) {
                mainWindow.show();
            }
        });
        let list = formatMenu(option.menus);
        let trayMenu = Menu.buildFromTemplate(list);
        tray.setContextMenu(trayMenu);
        tray.setImage(TrayImg);
        BrowserWindow.tray = tray;
        return tray;
    };
    return setMenu;
};