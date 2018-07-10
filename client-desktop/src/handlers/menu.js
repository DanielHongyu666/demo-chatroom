'use strict';
const {
    remote,
    shell,
    ipcRenderer
} = require('electron');
const {
    Menu,
    app,
    BrowserWindow
} = remote;

const Config = require('../config.js')
const platform = require('../utils').platform
var screenshot;
let AboutWindow, aboutWindow = null;

class MenuHandler {
    create(locale) {
        const template = this.getTemplate(locale);
        if (template) {
            const menuFromTemplate = Menu.buildFromTemplate(template);
            Menu.setApplicationMenu(menuFromTemplate);
            this.instance = menuFromTemplate;
        }
    }
    getTemplate(locale) {
        const darwinTemplate = [{
            label: locale.__('menus.Product').replace('RCE', Config.PACKAGE.APPNAME),
            submenu: [{
                    label: locale.__('menus.ProductSub.About').replace('RCE', Config.PACKAGE.APPNAME),
                    click: MenuHandler._about
                    // role: 'about'  // raw electron about menu
                },
                // {
                //   label: locale.__('menus.ProductSub.CheckUpdate'),
                //   click() {
                //     app.emit('menu.checkUpdate')
                //   }
                // },
                {
                    type: 'separator'
                }, {
                    label: locale.__('menus.ProductSub.Settings'),
                    click: MenuHandler._setting,
                    enabled: false
                }, {
                    type: 'separator'
                }, {
                    label: locale.__('menus.ProductSub.Services'),
                    role: 'services',
                    submenu: []
                }, {
                    type: 'separator'
                }, {
                    label: locale.__('menus.ProductSub.HApp').replace('RCE', Config.PACKAGE.APPNAME),
                    accelerator: 'Command+H',
                    role: 'hide'
                }, {
                    label: locale.__('menus.ProductSub.HOthers'),
                    accelerator: 'Command+Shift+H',
                    role: 'hideothers'
                }, {
                    label: locale.__('menus.ProductSub.SAll'),
                    role: 'unhide'
                }, {
                    type: 'separator'
                }, {
                    label: locale.__('menus.ProductSub.Quit'),
                    accelerator: 'Command+Q',
                    click: MenuHandler._quitApp,
                }
            ]
        }, {
            label: locale.__('menus.Edit'),
            submenu: [{
                label: locale.__('menus.EditSub.SearchUser'),
                accelerator: 'Command+F',
                click: MenuHandler._search,
                enabled: false
            }, {
                type: 'separator'
            }, {
                label: locale.__('menus.EditSub.Undo'),
                accelerator: 'Command+Z',
                role: 'undo'
            }, {
                label: locale.__('menus.EditSub.Redo'),
                accelerator: 'Shift+Command+Z',
                role: 'redo'
            }, {
                type: 'separator'
            }, {
                label: locale.__('menus.EditSub.Cut'),
                accelerator: 'Command+X',
                role: 'cut'
            }, {
                label: locale.__('menus.EditSub.Copy'),
                accelerator: 'Command+C',
                role: 'copy'
            }, {
                label: locale.__('menus.EditSub.Paste'),
                accelerator: 'Command+V',
                role: 'paste'
            }, {
                label: locale.__('menus.EditSub.SelectAll'),
                accelerator: 'Command+A',
                role: 'selectall'
            }]
        }, 
        {
            label: locale.__('menus.Window'),
            role: 'window',
            submenu: [{
                label: locale.__('menus.WindowSub.Minimize'),
                accelerator: 'Command+M',
                role: 'minimize'
            }, {
                label: locale.__('menus.WindowSub.Close'),
                accelerator: 'Command+W',
                role: 'close'
            }, {
                type: 'separator'
            }, {
                label: locale.__('menus.WindowSub.AllToFront'),
                role: 'front'
            }]
        }, {
            label: locale.__('menus.Application'),
            submenu: [{
                label: locale.__('menus.ApplicationSub.takeScreenshot'),
                accelerator: 'Command+Ctrl+S',
                enabled: true,
                click: MenuHandler._takeScreenshot,
            }]
        }, {
            label: locale.__('menus.Help'),
            role: 'help',
            submenu: [{
                label: locale.__('menus.HelpSub.Homepage'),
                click: MenuHandler._home,
            }, {
                label: locale.__('menus.HelpSub.Purgecache'),
                click: MenuHandler._purgeCache
            }]
        }];
        const linuxTemplate = [];
        if (platform.darwin) {
            return darwinTemplate;
        } else if (platform.linux) {
            return linuxTemplate;
        }
    }
    static _quitApp() {
        app.exit(0);
    }
    static _reload() {
        ipcRenderer.send('reload');
    }
    static _devTools() {
        remote.getCurrentWindow()
            .toggleDevTools();
    }
    static _update() {
        ipcRenderer.send('update');
    }
    static _setting() {
        ipcRenderer.send('open-settings');
    }
    static _takeScreenshot() {
        if(!screenshot){
            screenshot = require('../modules/screenshot/screenshot.render');
        }
        screenshot.start();
    }
    static _purgeCache() {
        ipcRenderer.send('purge-cache');
    }
    static _search() {
        ipcRenderer.send('search');
    }
    static _about() {
        shell.openExternal(Config.ABOUT);
    }
    static _home() {
        shell.openExternal(Config.HOME);
    }
    static _bringFront(isFront) {
        ipcRenderer.send('bring-front', isFront);
    }
    static _changeLanguage(language) {
        ipcRenderer.send('set-locale', language);
    }
    static showContextMenu(params) {
        let locale = params.locale;
        let inputMenu = [
            // {label: locale.__('context.Undo'), role: 'undo'},
            // {label: locale.__('context.Redo'), role: 'redo'},
            // {type: 'separator'},
            {label: locale.__('context.Cut'), role: 'cut'},
            {label: locale.__('context.Copy'), accelerator: 'Command+C', role: 'copy'},
            {label: locale.__('context.Paste'), accelerator: 'Command+V', role: 'paste'},
            {type: 'separator'},
            {label: locale.__('context.SelectAll'), role: 'selectall'},
        ]
        let selectionMenu = [
            {label: locale.__('context.Copy'), role: 'copy'},
            {type: 'separator'},
            {label: locale.__('context.SelectAll'), role: 'selectall'},
        ]
        var menuTemplate = params.isEditable ? inputMenu : selectionMenu;
        const contextMenu = Menu.buildFromTemplate(menuTemplate)
        contextMenu.popup(params.window);
    }

    static enableScreenshot(enabled) {
        var screenShotMenu = Menu.getApplicationMenu();
        if(screenShotMenu){
            screenShotMenu = screenShotMenu.items[3].submenu.items[0];
            screenShotMenu.enabled = enabled;
        }
    }
    // 设置 mac 下某些功能按钮在 logout 后不可用
    static enableAppMenu(enabled, key) {
        if (platform.win32 || platform.linux){
            return;
        }
        let menu = Menu.getApplicationMenu();
        let menuItem = {
            setting: menu.items[0].submenu.items[2],
            search: menu.items[1].submenu.items[0]
        };
        let setEnabled = function(_key, _enabled) {
            let curMenu = menuItem[_key];
            curMenu.enabled = _enabled;
        }
        if(key) {
            return setEnabled(key, enabled);
        }
        for(let _key in menuItem){
            setEnabled(_key, enabled);
        }
    }
}
module.exports = MenuHandler;