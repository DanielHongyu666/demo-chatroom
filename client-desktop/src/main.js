'use strict'
const electron = require('electron');
const {
    app,
    BrowserWindow,
    ipcMain,
    crashReporter
} = electron;
const path = require('path')
const i18n = require("i18n")
const Config = require('./config')
const Utils = require('./utils')
const platform = Utils.platform
// const AutoLaunch = require('auto-launch');
let dialog, logger;

// 远程控制相关. 关闭sunloginsdk进程, before-quit时使用
let stopRemoteClient;

// 终端运行命令, 判断运行 npm run demo
var argvs = process.argv.slice(2);
global.processENV = argvs[0];

let rceWindow = null;
//url 参数,主要用于 protocal 带参数进入
let urlParam = '';
let lastError = null;
let winState = [];

const startCrashReporter = () => {
    crashReporter.start({
        productName: Config.PACKAGE.APPNAME,
        companyName: Config.PACKAGE.AUTHOR,
        submitURL: `${Config.REPORT_URL}/post`,
        uploadToServer: true
    });
};

/*
集中处理 .node 文件的复制
因 自动升级不能直接替换 正在运行的 .node, 所以制作 .node 文件的替身来运行
 */
const copyNodeFile = () => {
    // Utils.moduleRename(Config.modules.screencapture);
    // Utils.moduleRename(Config.modules.rongimlib);
    // Utils.platform.win32 && Utils.moduleRename(Config.modules.remotecontrol);
};

var createRCEWindow = () => {
    const BrowserWin = require('./modules/window/window.main.js');
    // const BrowserWin = require('./modules/browser_window/browser_window.main.js');
    let option = Config.MAIN_WINDOW;
    if(global.processENV === 'demo'){
        option.url = `file://${path.join(__dirname, '/../', Config.DEMO_HOME)}`;
    } else {
        option.url = Config.APP_HOST + Config.APP_INDEX;
    }
    rceWindow = BrowserWin.create(option);
    BrowserWindow.mainWindow = rceWindow;
};
var createTray = () => {
    let AppTray = require('./modules/tray/tray.main.js');
    AppTray.setMenu({
        menus: AppTray.defaultMenus
    });
};

var initIpcEvents = () => {
    'use strict';
    require('./modules/system/system.main.js');
    require('./modules/app/app.main.js');
    ipcMain.on('notification-click', () => {
        if (rceWindow) {
            rceWindow.show()
        }
    })
    ipcMain.on('reload', () => {
        if (rceWindow) {
            rceWindow.reload()
        }
    })
    ipcMain.on('open-settings', () => {
        if (rceWindow) {
            rceWindow.show()
            rceWindow.setting()
        }
    })
    // Focus on search input element.
    ipcMain.on('search', () => {
        if (rceWindow) {
            rceWindow.search()
        }
    })
    ipcMain.on('bring-front', (event, isFront) => {
        if (rceWindow) {
            rceWindow.setAlwaysOnTop(isFront);
        }
    })
    ipcMain.on('set-locale', (event, lang) => {
        i18n.setLocale(lang);
        // globalEvents.emit('languageChanged', lang);
    })
};

var appReady = () => {
    'use strict';
    copyNodeFile();
    // 如放在后面初始化,页面加载完成后需要重新初始化菜单
    // require('./modules/screenshot/screenshot.main.js')
    createRCEWindow();
    createTray();
    initIpcEvents();
    initModules();
};

var initModules = () => {
    if(!dialog){
        dialog = require('./common/dialog')
    }
    if(!logger){
        logger = require('./common/logger');
    }
};

var initApp = () => {
    'use strict';
    // process.setMaxListeners(0)
    // require('events').EventEmitter.defaultMaxListeners = 0
    app.commandLine.appendSwitch('ignore-certificate-errors');
    app.commandLine.appendSwitch('remote-debugging-port', Config.DEBUGOPTION.PORT);
    startCrashReporter();
    if (platform.win32) {
        app.setAppUserModelId(Config.APP_ID)
    }
    app.on('ready', appReady);
    app.on('activate', () => {
        if(!rceWindow.isVisible()){
            rceWindow.show();
            winState.length = 0;
            return;
        }
        var isWinHide = false;
        if(winState[0] == 'focus' && winState[1] == 'blur'){
            isWinHide = true;
            winState.unshift('focus');
            winState.length = 2;
        }

        if (rceWindow) {
            if(isWinHide){
                rceWindow.show()
            } else {
                rceWindow.dockClick && rceWindow.dockClick();
            }
        }
    })
    app.on('before-quit', () => {
        // 远程控制相关, 关闭 sunloginsdk 进程, 避免遗留
        stopRemoteClient && stopRemoteClient();
        if (rceWindow) {
            global.forceQuit = true;
        }
    })
    app.on('window-all-closed', () => {
        app.quit()
    })
    app.on('open-url', function(event, url) {
        if (mainWindow) {
            /*
            应用通过URI-Scheme打开时, 传入参数处理
            url格式: rce://a=1&b=2&c=3, params最终为 { a: 1, b: 2, c: 3 }
             */
            var params = Utils.getQueryParams(url);
            mainWindow.webContents.send('open-url', params);
        }
        event.preventDefault();
        urlParam = url;
    });
    app.on('menu.view.bringFront', (checked) => {
        if(rceWindow){
            rceWindow.setAlwaysOnTop(checked);
        }
    })
    app.on('browser-window-blur', () => {
        winState.unshift("blur");
    })

    app.on('browser-window-focus', () => {
        winState.unshift("focus");
    })
};
(() => {
    let shouldQuit = app.makeSingleInstance((argv, workingDirectory) => {
        // Someone tried to run a second instance, we should focus our window
        if (rceWindow) {
            rceWindow.show()
        }
        return true
    })
    if (shouldQuit) {
        app.quit()
    }
    global.locale = {}
    i18n.configure({
        locales: ['en', 'zh-CN'],
        directory: __dirname + '/locales',
        objectNotation: true,
        register: global.locale,
        defaultLocale: 'zh-CN'
    });
    initApp();
})();

process.on('error', function(err) {
    logger.error(err.toString());
});

process.on('uncaughtException', function(error) {
    console.log(error)
    logger.error(error);
    lastError = error.stack;

    if(rceWindow){
        rceWindow.sendCommand('logError', error.stack);
    } else {
        dialog.showError(error);
    }
});
// 内嵌站点程序
require('../src/modules/server/server');

