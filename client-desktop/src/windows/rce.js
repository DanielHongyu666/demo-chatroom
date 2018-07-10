/**
 * Created by Zhengyi on 5/2/17.
 */
'use strict';
const electron = require('electron')
const fs = require('fs')
const path = require('path');
const url = require('url');
const AppConfig = require('../configuration');
// const isXfce = require('is-xfce');
const {
    app,
    shell,
    BrowserWindow,
    session,
    globalShortcut
} = require('electron');
const Config = require('../config.js')
const Utils = require('../utils')
const platform = Utils.platform

const shortcuts = {
    'darwin': {
        devTools: 'Ctrl+Cmd+Shift+I',
        shake: 'Ctrl+Cmd+X'
    },
    'win32': {
        search: 'Ctrl+F',
        devTools: 'Ctrl+Alt+Shift+I',
        shake: 'Ctrl+Alt+X'
    }
}
const appShortcuts = shortcuts[process.platform];

let shake = null
var clearShake = function() {
    if (shake) {
        clearInterval(shake)
    }
    shake = null
}
var saveWindowBounds = (bounds) => {
    AppConfig.saveSettings('x', bounds.x);
    AppConfig.saveSettings('y', bounds.y);
    AppConfig.saveSettings('width', bounds.width);
    AppConfig.saveSettings('height', bounds.height);
};

var handleImage = function(item) {
    item.once('done', (event, state) => {
        if (state === 'completed') {
            var fileName = item.getFilename();
            if (fileName.indexOf('.') == -1) {
                var filePath = item.getSavePath();
                fs.rename(filePath, filePath + '.png', function(err) {
                    if (err) {
                        logger.error('rename file error:' + filePath);
                    }
                });
            }
            console.log(item.getMimeType(), item.getFilename());
        } else {
            console.log(`Download failed: ${state}`)
        }
    })
}

class RCEWindow {
    constructor(winBounds, winLocation) {
        this.isShown = false;
        this.isFocused = false;
        // this.loginState = { NULL: -2, WAITING: -1, YES: 1, NO: 0 };
        // this.loginState.current = this.loginState.NULL;
        // this.inervals = {};
        this.createWindow(winBounds, winLocation);
        this.initRCEWindowShortcut();
        this.initWindowEvents();
        this.initWindowWebContent();
        this.forceQuit = false;
    }
    resizeWindow(isLogged, splashWindow) {
        // const size = isLogged ? Common.WINDOW_SIZE : Common.WINDOW_SIZE_LOGIN;
        // this.rceWindow.setResizable(isLogged);
        // this.rceWindow.setSize(size.width, size.height);
        /*if (this.loginState.current === 1 - isLogged || this.loginState.current === this.loginState.WAITING) {
          splashWindow.hide();
          this.show();
          this.rceWindow.center();
          this.loginState.current = isLogged;
        }*/
    }
    createWindow(winBounds, winLocation) {
        var mainConfig = {
            x: winLocation.x,
            y: winLocation.y,
            width: winBounds.width,
            height: winBounds.height,
            minWidth: 890,
            minHeight: 640,
            titleBarStyle: 'hidden',
            // icon: path.join(__dirname, 'res', Config.WINICON),
            title: Config.PACKAGE.APPNAME,
            show: false,
            frame: false,
            // alwaysOnTop: true,
            'webPreferences': {
                preload: path.join(__dirname, '..', 'inject', 'preload.js'),
                nodeIntegration: false,
                allowDisplayingInsecureContent: true,
                webSecurity: false,
                plugins: true
            }
        };
        /*if (platform.linux) {
            windowConfig.icon = path.join(__dirname, 'res', Config.PACKAGE.LINUX.APPICON);
        }*/
        this.rceWindow = new BrowserWindow(mainConfig);
    }
    loadURL(url) {
        this.rceWindow.loadURL(url);
    }
    isVisible(){
        return this.rceWindow.isVisible();
    }
    show() {
        this.rceWindow.show();
        this.rceWindow.focus();
        // this.rceWindow.webContents.send('show-rce-window');
        this.isShown = true;
    }
    hide() {
        this.rceWindow.hide();
        // this.rceWindow.webContents.send('hide-rce-window');
        this.isShown = false;
    }
    connectRCE() {
        this.loadURL(`file://${path.join(__dirname, '/../index.html')}`);
    }
    connectDemo() {
        this.loadURL(`file://${path.join(__dirname, '/../../', Config.DEMO_HOME)}`);
    }
    reload() {
        this.rceWindow.webContents.reloadIgnoringCache()
    }
    search() {
        this.rceWindow.webContents.send('menu.edit.search');
    }
    setting() {
        this.rceWindow.webContents.send('menu.main.account_settings');
    }
    doubleClick() {
        this.rceWindow.webContents.send('onDoubleClick');
    }
    balloonClick(opt) {
        this.rceWindow.webContents.send('balloon-click', opt);
    }
    voipClose() {
        this.rceWindow.webContents.send('onClose', '');
    }
    voipReady(winid) {
        if (this.rceWindow) {
            this.rceWindow.webContents.send('onVoipReady', winid);
        }
    }
    voipRequest(params) {
        this.rceWindow.webContents.send('onVoipRequest', params);
    }
    upgrade() {
        this.rceWindow.webContents.send('onUpgraded');
    }
    dockClick() {
        this.rceWindow.webContents.send('onDockClick');
    }
    /*logError(err) {
        this.rceWindow.webContents.send('logError', err);
    }*/
    flashFrame(enabled) {
        this.rceWindow.flashFrame(enabled);
    }
    setAlwaysOnTop(checked) {
        this.rceWindow.setAlwaysOnTop(checked);
    }
    toggleDevTools() {
        this.rceWindow && this.rceWindow.webContents.toggleDevTools();
    }
    clearCache() {
        if (!this.rceWindow) return
        let session = this.rceWindow.webContents.session
        new Promise(rslv => session.clearCache(() => rslv()))
            .then(() => new Promise(rslv => session.clearStorageData(() => rslv())))
            .then(() => loadHome())
    }
    isAlwaysOnTop() {
        return this.rceWindow.isAlwaysOnTop();
    }
    execShake(flag) {
        var _position;
        if (this.rceWindow) {
            _position = this.rceWindow.getPosition()
            if (flag) {
                this.rceWindow.setPosition(_position[0] + 10, _position[1])
            } else {
                this.rceWindow.setPosition(_position[0] - 10, _position[1])
            }
        }
    }
    /**
     * [shakeWindow description]
     * @param config {
     *    interval:number [振动频率]
     *    time :number [振动时间]
     * }
     */
    shakeWindow(config) {
        config = config || {};
        if (this.rceWindow) {
            var flag = false;
            clearShake();
            if (typeof config.interval != 'number') {
                config.interval = 25;
            }
            if (typeof config.time != 'number') {
                config.time = 1000;
            }
            shake = setInterval(() => {
                flag = !flag;
                this.execShake(flag);
            }, config.interval);
            setTimeout(() => {
                clearShake()
            }, config.time)
        }
    }
    initWindowWebContent() {
        // this.rceWindow.webContents.setUserAgent(Common.USER_AGENT[process.platform]);
        var webContents = this.rceWindow.webContents;
        if(global.processENV === 'demo'){
            this.connectDemo();
        } else {
            this.connectRCE();
        }
        
        webContents.on('dom-ready', () => {
            var cssfile = path.join(__dirname, '/../inject/browser_win.css');
            if (platform.darwin) {
                cssfile = path.join(__dirname, '/../inject/browser_mac.css');
            }
            webContents.insertCSS(fs.readFileSync(cssfile, 'utf8'));
            webContents.executeJavaScript(fs.readFileSync(path.join(__dirname, '/../inject/postload.js'), 'utf8'));
        })
        webContents.on('did-finish-load', () => {
            webContents.loadFinished = true;
            this.rceWindow.show();
            if (global.processENV === 'dev') {
                // var options = {mode: 'undocked'};
                // webContents.openDevTools(options);
                webContents.openDevTools();
            }
        });
        webContents.on('new-window', (event, url) => {
            console.log('rce open new ' + url);
            event.preventDefault()
            shell.openExternal(url)
        })
        webContents.on('devtools-opened', () => {
            // this.unregShortCut();
        });
        webContents.on('devtools-closed', () => {
            // this.regShortCut();
        });
        webContents.on('context-menu', (e, props) => {
            var params = {
                window: this.rceWindow,
                props: props
            };
            webContents.send('contextMenu', params);
        })
        webContents.on('new-window', (event, url) => {
            /*event.preventDefault();
            shell.openExternal(new MessageHandler()
                .handleRedirectMessage(url));*/
        });
        webContents.on('will-navigate', (event, url) => {
            // if (url.endsWith('/fake')) event.preventDefault();
        });
    }
    clearAllListeners() {
        BrowserWindow.getAllWindows().forEach(function(win){
            win.removeAllListeners();
        });
    }
    initWindowEvents() {
        var context = this;
        this.rceWindow.on('focus', () => {
            context.isFocused = true;
            this.registerLocalShortcut();
        });
        this.rceWindow.on('blur', () => {
            context.isFocused = false;
            this.unregisterLocalShortcut();
        });
        this.rceWindow.on('show', () => {
            // this.registerLocalShortcut();
        });
        this.rceWindow.on('hide', () => {
            this.rceWindow.webContents.send('hide')
        });
        this.rceWindow.on('close', (event) => {
            console.log('todo:deal with blink, test in windows');
            if (this.forceQuit) {
                if (this.rceWindow && this.rceWindow.webContents) {
                    this.rceWindow.webContents.send('lougout')
                }
                // this.unregisterLocalShortcut();
                globalShortcut.unregisterAll();
                // this.rceWindow && this.rceWindow.removeAllListeners();
                this.clearAllListeners();
                app.exit(0);
            } else {
                event.preventDefault()
                if (this.rceWindow.isFullScreen()) {
                    this.rceWindow.setFullScreen(false)
                } else {
                    this.rceWindow.hide()
                }
            }
        })
        this.rceWindow.on('closed', () => {
            this.rceWindow.removeAllListeners();
            this.rceWindow = null;
        })
        this.rceWindow.on('maximize', () => {
            this.rceWindow.webContents.send('change-win-state', 'maximize')
        })
        this.rceWindow.on('unmaximize', () => {
            this.rceWindow.webContents.send('change-win-state', 'unmaximize')
        })
        this.rceWindow.on('resize', function () {
            let bounds = this.getBounds()
            bounds && saveWindowBounds(bounds)
        })

        this.rceWindow.on('move', function () {
            let bounds = this.getBounds()
            bounds && saveWindowBounds(bounds)
        })
    }
    regShortCut() {
        if (globalShortcut.isRegistered(appShortcuts.search)) {
            return;
        }
        globalShortcut.register(appShortcuts.search, () => {
            this.search();
        });
    }
    unregShortCut() {
        if (globalShortcut.isRegistered(appShortcuts.search)) {
            globalShortcut.unregister(appShortcuts.search);
        }
    }
    registerLocalShortcut() {
        if (platform.darwin) {
            globalShortcut.register(appShortcuts.devTools, () => {
                this.toggleDevTools();
            });
            globalShortcut.register(appShortcuts.shake, () => {
                this.shakeWindow();
            });
        } else {
            globalShortcut.register(appShortcuts.devTools, () => {
                this.toggleDevTools();
            });
            globalShortcut.register(appShortcuts.shake, () => {
                this.shakeWindow();
            });
            this.regShortCut();
           /* globalShortcut.register('Ctrl+R', () => {
                this.reload();
            });*/
        }
    }
    unregisterLocalShortcut() {
        // globalShortcut.unregisterAll();
        for (var key in appShortcuts){
            globalShortcut.unregister(appShortcuts[key])
        }
    }
    initRCEWindowShortcut() {
        this.registerLocalShortcut();
    }
    getBounds() {
        return this.rceWindow.getBounds();
    }
    getWorkAreaSize() {
        var bounds = this.getBounds();
        var display = electron.screen.getDisplayMatching(bounds);
        return display.workAreaSize;
    }
    enableForceQuit() {
        this.forceQuit = true;
    }
    sendCommand(commond, params) {
        if(this.rceWindow.isDestroyed()){
            return;
        }
        if (this.rceWindow && this.rceWindow.webContents) {
            this.rceWindow.webContents.send(commond, params);
        }
    }
}
module.exports = RCEWindow;