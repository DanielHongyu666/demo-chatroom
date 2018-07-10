'use strict';
/*
窗口级独立模块, 不依赖任何逻辑
Electron BrowserWindow 文档: https://electronjs.org/docs/api/browser-window
 */
const {
    app,
    ipcMain,
    BrowserWindow,
    screen,
    globalShortcut
} = require('electron');
const path = require('path');
const fs = require('fs');
const Utils = require('../../utils.js');
const AppConfig = require('./configuration.js');
let ConfigInfo;
try {
    ConfigInfo = require('../../config.js')
} catch (err) {
    ConfigInfo = null
}
const platform = Utils.platform

// 打开控制台调试的快捷键
const shortcuts = {
    'darwin': {
        devTools: 'Ctrl+Cmd+Shift+I'
    },
    'win32': {
        devTools: 'Ctrl+Alt+Shift+I'
    }
};
const appShortcuts = shortcuts[process.platform];

/**
 * this.window 
 */
class Window {
    /**
     * 初始化
     * @param  {object} option 设置项
     *                  option.xxx     选填, 详见下方 createWindow 方法
     */
    constructor(option) {
        let url = option.url;
        let isLocal = option.isLocal;
        this.id = option.id || option.url;
        this.option = option;
        this.createWindow(option);
        this.loadURL(url, isLocal);
        this.forceQuit = false;
        this.setSendCommand();
        return this.window;
    }
    /*
     * option 参数见: https://electronjs.org/docs/api/browser-window#class-browserwindow
     * option.backgroundColor  选填, 窗口的背景颜色
     * option.width   选填, 默认项见 createWindow 方法的 defaultOpt
     * ...            选填, 详见 createWindow 方法的 defaultOpt
     * 注: option新增咱叔, url, url, 为窗口加载的 url
     * 注: option新增参数, top, left, bottom, right, 用来设置窗口坐标
     */
    createWindow(option) {
        const startTime = new Date().getTime();
        let defaultOpt = {
            width: 890,
            height: 640,
            titleBarStyle: 'hidden',
            show: false,
            frame: false,
            'webPreferences': {
                preload: path.join(__dirname, '..', '..', 'inject', 'preload.js'),
                nodeIntegration: false,
                allowDisplayingInsecureContent: true,
                webSecurity: false,
                plugins: true
            }
        };
        
        // 处理配置项
        option = Utils.extend(defaultOpt, option);
        let bounds = this.getBounds(option);
        option = Utils.extend(option, bounds);
        // 开始创建
        let newWindow = new BrowserWindow(option);
        let isShow = option.show;
        // 避免显示窗口时有视觉闪烁
        !isShow && newWindow.once('ready-to-show', () => {
            const showTime = new Date().getTime();
            console.log('time: ', showTime - startTime);
            newWindow.show();
        });
        this.window = newWindow;
        this.setWindowWebContents();
        this.setWindowEvents();
    }
    loadURL(url, isLocal) {
        // let appHost = isLocal ? ConfigInfo.appHost : '';
        let appHost = isLocal ? ConfigInfo.APP_HOST : '';
        url = appHost + url;
        this.window.loadURL(url);
    }
    getBounds(option) {
        let bounds = this.getPosition(option);
        if (option.xxx || 1) {
            let latestSetting = AppConfig.readSettings(option.url);
            bounds = Utils.extend(bounds, latestSetting);
        }
        return bounds;
    }
    getPosition(option) {
        let screenSize = screen.getPrimaryDisplay()
        .size;
        let windowSize = {
            width: option.width,
            height: option.height
        };
        let x = (screenSize.width - (option.width || 890)) / 2;
        let y = (screenSize.height - (option.height || 640)) / 2;
        let position = option.position || {};
        if (position.bottom || position.bottom === 0) {
            y = screenSize.height - position.bottom - windowSize.height;
        }
        if (position.right || position.right === 0) {
            x = screenSize.width - position.right - windowSize.width;
        }
        let left = option.x || position.left;
        if (left || left === 0) {
            x = left;
        }
        let top = option.y || position.top;
        if (top || top === 0) {
            y = top;
        }
        return {
            x: x,
            y: y
        };
    }
    setSendCommand() {
        let win = this.window;
        win.sendCommand = (commond, params) => {
            if(win.isDestroyed()){
                return;
            }
            if (win && win.webContents) {
                win.webContents.send(commond, params);
            }
        };
    }
    // webContents 事件, 例: dom-ready
    setWindowWebContents() {
        let webContents = this.window.webContents;
        // webContents.openDevTools();
        webContents.on('new-window', (event, url) => {
            const { shell } = require('electron');
            event.preventDefault();
            shell.openExternal(url);
        });
        webContents.on('dom-ready', () => {
            webContents.executeJavaScript(fs.readFileSync(path.join(__dirname, '../../inject/postload.js'), 'utf8'));
        });
    }
    // 设置 window 事件, 例: window.on('focus')
    setWindowEvents() {
        let context = this;
        let win = this.window;
        let option = this.option;
        win.on('resize', () => {
            let bounds = win.getBounds();
            bounds && AppConfig.saveSettings(option.url, bounds);
        });
        win.on('move', () => {
            let bounds = win.getBounds();
            bounds && AppConfig.saveSettings(option.url, bounds);
        });
        win.on('focus', () => {
            context.registerLocalShortcut();
        });
        win.on('blur', () => {
            context.unregisterLocalShortcut();
        });
        win.on('close', (event) => {
            if (this.window != BrowserWindow.mainWindow) {
                let id = option.id || option.url;
                BrowserWindow.WindowHandler.remove(id);
                return;
            }
            if (global.forceQuit) {
                app.exit(0);
            } else {
                event.preventDefault()
                if (this.window.isFullScreen()) {
                    this.window.setFullScreen(false)
                } else {
                    this.window.hide()
                }
            }
        });
    }

    registerLocalShortcut() {
        globalShortcut.register(appShortcuts.devTools, () => {
            this.window.toggleDevTools();
        });
    }

    unregisterLocalShortcut() {
        for (var key in appShortcuts){
            globalShortcut.unregister(appShortcuts[key])
        }
    }
}

/*
打开后的 window, 存储在 electron.BrowserWindow 变量中
 */
const WindowHandler = {
    saveId: 'OpenedBrowserWindow',

    // 根据 id 获取对应的 window
    get: (id) => {
        let OpenedWindow = BrowserWindow[WindowHandler.saveId] || {};
        return OpenedWindow[id];
    },
    // 获取所有已打开的窗口数据, 返回数组
    getAll: () => {
        return BrowserWindow[WindowHandler.saveId] || [];
    },
    // 删除存储中的窗口数据
    remove: (id) => {
        let windows = BrowserWindow[WindowHandler.saveId];
        if (windows && windows[id]) {
            delete BrowserWindow[WindowHandler.saveId][id];
        }
    },
    save: function(id, browserWin) {
        let saveId = WindowHandler.saveId;
        if (!BrowserWindow[saveId]) {
            BrowserWindow[saveId] = {};
        }
        BrowserWindow[saveId][id] = browserWin;
    }
};
BrowserWindow.WindowHandler = WindowHandler;

/**
 * 对外暴露的 create 方法
 * @param  {object} option 见 Window 的 constructor
 */
const create = (option) => {
    let id = option.id || option.url;
    // 如果该弹框已存在, 直接 focus
    let browserWin = WindowHandler.get(id);
    if (browserWin) {
        browserWin.focus();
        return;
    }
    let newWindow = new Window(option);
    newWindow.on('closed', function() {
        newWindow = null;
        WindowHandler.remove(id);
    });
    WindowHandler.save(id, newWindow);
    return newWindow;
};

/**
 * 对外暴露, 关闭所有已打开的窗口
 * TODO 待商议, 是否暴露
 */
const closeAll = () => {
    app.quit();
};

/**
 * 对外暴露, 关闭对应 id 的窗口
 */
const close = (id) => {
    if (id) {
        let browserWin = WindowHandler.get(id);
        browserWin && browserWin.close();
        WindowHandler.remove(id);
    }
};

/**
 * @param  {key}    key  消息的key
 * @param  {...[type]} args  发送的消息参数
 */
const sendMessage = (key, ...args) => {
    let openedWindow = WindowHandler.getAll();
    for (let id in openedWindow) {
        let browserWin = WindowHandler.get(id)
        browserWin.webContents.send(key, ...args);
    }
    // 为匹配现有代码而加入mainWindow. 之后将删除
    // let mainWindow = BrowserWindow.mainWindow.rceWindow;
    // mainWindow.webContents.send(key, ...args);

};

const setIpcMain = () => {
    const mark = 'browser_window';
    const createMark = `${mark}_create`;
    const messageMark = `${mark}_message`;
    // 监听 browser_window.render.js 中的 ipcRenderer.send, 使该方法可以用于渲染进程
    ipcMain.on(createMark, (event, option) => {
        create(option);
    });
    // 监听窗口间的通讯
    ipcMain.on(messageMark, (event, key, ...args) => {
        sendMessage(key, ...args);
    });
};

setIpcMain();

module.exports = {
    create: create,
    close: close,
    closeAll: closeAll
};
