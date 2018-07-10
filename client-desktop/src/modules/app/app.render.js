'use strict';
const {
    ipcRenderer,
    remote
} = require('electron');
const {
    app,
    Menu
} = remote;
const utils = require('../../utils.js');
const platform = utils.platform;

// 将所有 submenus 转化为 electron 需要的 submenu
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

// 设置 App 的菜单, 仅 Mac 存在, 位置默认在屏幕左上角
const setMenu = (option) => {
    if (!platform.win32 && option.menus) {
        let menu = formatMenu(option.menus);
        menu = Menu.buildFromTemplate(menu);
        Menu.setApplicationMenu(menu);
    }
};

let _exports = {
    isAutostart: false,
    enableAutostart: () => {
        setAutoLaunch(true);
    },
    disableAutostart: () => {
        setAutoLaunch(false);
    },
    quit: () => {
        app.quit();
    },
    restart: () => {
        ipcRenderer.send('app-relaunch');
    },
    setMenu: setMenu
};

// 记录是否开机自启动
app.minecraftAutoLauncher.isEnabled().then((isEnabled) => {
    _exports.isAutostart = isEnabled;
}).catch((err) => {
});

const setAutoLaunch = (isEnabled) => {
    ipcRenderer.send('set-auto-launch', isEnabled);
    _exports.isAutostart = isEnabled;
};

module.exports = _exports;