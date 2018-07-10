const {
    remote, 
    ipcRenderer
} = require('electron');
const currentWindow = remote.getCurrentWindow()
const platform = {
    win32: /^win/i.test(process.platform),
    darwin: /^darwin/i.test(process.platform),
    linux: /^linux/i.test(process.platform)
};

const ShakeHandler = {
    interval: null,
    start: (config) => {
        config = config || {};
        let flag = false;
        ShakeHandler.stop();
        if (typeof config.rate !== 'number') {
            config.rate = 25;
        }
        if (typeof config.time !== 'number') {
            config.time = 1000;
        }
        ShakeHandler.interval = setInterval(() => {
            flag = !flag;
            ShakeHandler.shake(flag);
        }, config.rate);
        setTimeout(() => {
            ShakeHandler.stop();
        }, config.time);
    },
    stop: () => {
        if (ShakeHandler.interval) {
            clearInterval(ShakeHandler.interval);
        }
        ShakeHandler.interval = null;
    },
    shake: (flag) => {
        let position = currentWindow.getPosition();
        let x = position[0], y = position[1];
        x = flag ? x + 10 : x - 10;
        currentWindow.setPosition(x, y);
    }
};

const isMainWindow = () => {
    let BrowserWindow = remote.BrowserWindow;
    return BrowserWindow.mainWindow === currentWindow;
};

const closeOther = () => {
    // 'OpenedBrowserWindow' 定义于 window.main.js
    let openedWindows = remote.BrowserWindow.OpenedBrowserWindow;
    for (let key in openedWindows) {
        let win = openedWindows[key];
        if (win !== currentWindow) {
            win.close();
        }
    }
};

const Current = {
    isMain: isMainWindow,
    closeOther: closeOther,
    isFocus: () => {
        return currentWindow.isFocused();
    },
    isBlur: () => {
        return !Current.isFocus();
    },
    max: () =>  {
        currentWindow.maximize();
    },
    isMax: () => {
        return currentWindow.isMaximized();
    },
    min: () =>  {
        currentWindow.minimize();
    },
    isMin: () => {
        currentWindow.isMinimized();
    },
    restore: () =>  {
        if(currentWindow.isMinimized()){
            currentWindow.show();
        }
        if(currentWindow.isMaximized()){
            currentWindow.unmaximize();
        }
    },
    setAlwaysOnTop: (isOnTop) => {
        isOnTop = isOnTop || false;
        currentWindow.setAlwaysOnTop(isOnTop);
    },
    isAlwaysOnTop: () => {
        return currentWindow.isAlwaysOnTop();
    },
    isHide: () => {
        return !currentWindow.isVisible();
    },
    isShow: () => {
        return currentWindow.isVisible();
    },
    shake: (config) => {
        ShakeHandler.start(config);
    },
    flash: (enabled) => {
        if (enabled === undefined) {
            enabled = true;
        }
        platform.win32 && currentWindow.flashFrame(enabled);
    }
    // mac only
    // updateBadge: (content) => {
    //     platform.darwin && ipcRenderer.send('badge-changed', content);
    // },
    // // windows only
    // showTrayBlink: (enabled) => {
    //     if (enabled === undefined) {
    //         enabled = true;
    //     }
    //     ipcRenderer.send('tray-blink', enabled);
    // },
    // // windows win7+ only
    // displayBalloon: (title, content) => {
    //     if (platform.win32 && title && content) {
    //         ipcRenderer.send('display-balloon', title, content)
    //     }
    //     if (!title || !content) {
    //         console.error(`'title' and 'content' must be defined`);
    //     }
    // },
    // // windows only;  Don’t forget to call the flashFrame method with false to turn off the flash. In the above example, it is called when the window comes into focus, but you might use a timeout or some other event to disable it.
    // flashFrame: (enabled) => {
    //     if (enabled === undefined) {
    //         enabled = true;
    //     }
    //     platform.win32 && currentWindow.flashFrame(enabled);
    // },
    // shakeWindow: (config) => {
    //     ShakeHandler.start(config);
    // },
    // quit: () => {
    //     ipcRenderer.send('quit')
    // }
};

/*
 currentWindow 自身包含方法:
        close, focus, isFocused, blur, hide, show, isVisible
 */
module.exports = Object.assign(currentWindow, Current);