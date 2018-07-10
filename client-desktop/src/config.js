'use strict';
let fs = require('fs')
const path = require('path')
let ConfigIniParser = require("config-ini-parser")
    .ConfigIniParser;
let delimiter = "\n"; //or "\n" for *nux
let parser = new ConfigIniParser(delimiter); //If don't assign the parameter delimiter then the default value \n will be used
let localConfig = path.join(__dirname, 'local_config.conf')
let iniContent = fs.readFileSync(localConfig, 'utf-8');
parser.parse(iniContent);
let reportUrl = parser.get("base", "reporturl");
let appHost = parser.get("base", "apphost");
let appIndex = parser.get("base", "appindex");
let home = parser.get("base", "home");
let appId = parser.get("base", "appid");
let protocal = parser.get("base", "protocal");
let productName = parser.get("base", "productname");
let appName = parser.get("base", "appname");
let build = parser.get("base", "build");
let description = parser.get("base", "description");
let author = parser.get("base", "author");
let runTimeVersion = parser.get("base", "runtimeversion");
let version = parser.get("base", "version");

let im_config = {
    //############ 以下为必改项 ##############
    //http://electron.atom.io/docs/api/crash-reporter/
    REPORT_URL: reportUrl,
    APP_HOST: appHost,
    APP_INDEX: appIndex,
    DEMO_HOME: 'demo2/index.html',
    //############  以上为必改项  ##############
    APP_ID: appId,
    HOME: home,
    PROTOCAL: protocal,
    ABOUT: 'http://www.rongcloud.cn/docs/desktop.html',
    SUPPORT: {
        CSDK: true,
        SCREENSHOT: true
    },
    MAIN_WINDOW: {
        width: 1000,
        height: 640,
        minWidth: 960,
        minHeight: 640,
        alwaysOnTop: false,
        title: appName
    },
    // windows 图标
    WIN: {
        //  WINDOWS ONLY,TRAY BLINK ON
        //  new Tray,tray.setImage    
        TRAY: 'Windows_icon.png',
        //  WINDOWS ONLY,TRAY BLINK OFF
        //  tray.setImage
        TRAY_OFF: 'Windows_Remind_icon.png',
        TRAY_DROP: 'Windows_offline_icon.png',
        //  tray.displayBalloon
        BALLOON_ICON: 'app.png'
    },
    // Mac 图标
    MAC: {
        TRAY: 'Mac_Template.png',
        PRESSEDIMAGE: 'Mac_TemplateWhite.png',
        TRAY_OFF: 'Mac_Remind_icon_white.png'
    },
    // 打包程序相关
    PACKAGE: {
        //以下参数设置需对照 配置说明 中 4 项列出的工具参数理解
        PRODUCTNAME: productName,
        APPNAME: appName,
        VERSION: version,
        DESCRIPTION: description,
        AUTHOR: author,
        RUNTIMEVERSION: runTimeVersion,
        COPYRIGHT: "",
        WIN: {
            APPICON: 'app.ico',
            ICON_URL: 'http://7i7gc6.com1.z0.glb.clouddn.com/image/sealtalk.ico',
            LOADING_GIF: '../res/loading.gif'
        },
        MAC: {
            APPICON: 'app.icns',
            BACKGROUND: 'bg.png'
            //CF_BUNDLE_VERSION: '1.0.3'
        },
        LINUX: {
            APPICON: 'app.png'
        }
    },
    modules: {
        screencapture: {
            url: './modules/screenshot/{platform}',
            oriname: 'screencapture.node',
            newname: 'screencapture_process.node'
        },
        rongimlib: {
            url: './modules/ronglib/{platform}',
            oriname: 'RongIMLib.node',
            newname: 'RongIMLib_process.node'
        },
        remotecontrol: {
            url: './modules/remote_control/win32',
            oriname: 'remotecontrol.node',
            newname: 'remotecontrol_process.node'
        }
    },
    DEBUG: true,
    DEBUGOPTION: {
        // vue 插件地址, 需配置
        VUEPATH: '/Users/user/Library/Application Support/Google/Chrome/Default/Extensions/nhdogjmejiglipccpnnnanhbledajbpd/4.1.4_0',
        PORT: '48075'
    }
};
let isTest = true;
if (build == 'Debug') {
    isTest = true;
} else {
    isTest = false;
}
if (isTest) {
    im_config.APP_ID += 'TEST';
    im_config.PROTOCAL += 'TEST';
    im_config.PACKAGE.APPNAME += 'TEST';
    im_config.PACKAGE.PRODUCTNAME += 'TEST';
    im_config.PACKAGE.DESCRIPTION = "RCE TEST Desktop Application.";
}
module.exports = im_config;