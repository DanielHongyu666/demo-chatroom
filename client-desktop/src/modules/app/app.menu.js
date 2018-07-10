'use strict';
const {
    remote,
    shell
} = require('electron');
const {
    app,
    BrowserWindow
} = remote;

let mainWindow = BrowserWindow.mainWindow;
const utils = require('../../utils.js');
const platform = utils.platform;
const locale = remote.getGlobal('locale');
const Config = require('../../config.js');

const openAbout = () => {
    shell.openExternal(Config.ABOUT)  ;
};
const hideMainWindow = () => {
    mainWindow.hide();
};
const minMainWindow = () => {
    mainWindow.min();
};
const frontMainWindow = (isFront) => {
    mainWindow.setAlwaysOnTop(isFront);
};
const quitApp = () => {
    app.quit();
};

const getDefaultMenu = () => {
    return [
        {
            label: locale.__('menus.Product').replace('RCE', Config.PACKAGE.APPNAME),
            submenus: [
                {
                    label: locale.__('menus.ProductSub.About').replace('RCE', Config.PACKAGE.APPNAME),
                    click: openAbout
                },
                {
                    type: 'separator'
                },
                {
                    label: locale.__('menus.ProductSub.HApp').replace('RCE', Config.PACKAGE.APPNAME),
                    click: hideMainWindow
                },
                {
                    label: locale.__('menus.ProductSub.HOthers'),
                    role: 'hideothers'
                },
                {
                    label: locale.__('menus.ProductSub.SAll'),
                    role: 'unhide'
                },
                {
                    type: 'separator'
                },
                {
                    label: locale.__('menus.ProductSub.Quit'),
                    accelerator: 'Command+Q',
                    click: quitApp,
                }
            ]
        },
        {
            label: locale.__('menus.Window'),
            submenus: [{
                label: locale.__('menus.WindowSub.Minimize'),
                click: minMainWindow
            }, {
                label: locale.__('menus.WindowSub.Close'),
                click: hideMainWindow
            }, {
                type: 'separator'
            }, {
                label: locale.__('menus.WindowSub.AllToFront'),
                type: 'checkbox',
                click: (item) => {
                    frontMainWindow(item.checked);
                }
            }]
        }
    ];
};

module.exports = getDefaultMenu();
