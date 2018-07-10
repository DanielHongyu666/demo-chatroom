'use strict';
const saveFileName = 'rong_window_setting.json';

/*
  将每个窗口的配置项存入文件, 用来提供下次启动的默认值
  文件格式如:
    {
        "http://www.rongcloud.cn": {
            width: 680,
            height: 550,
            x: 300,
            y: 100
        },
        "http://support.rongcloud.cn": {
            width: 1080,
            height: 780,
            x: 0,
            y: 0
        }
    }
 */

const getConfigPath = () => {
    const utils = require('../../utils.js');
    const fs = require('fs');
    const { app } = require('electron');
    const path = require('path');
    let configPath = app.getPath('userData');
    configPath = path.join(configPath, saveFileName);
    if (!utils.fileExists(configPath)) {
        fs.writeFileSync(configPath, '{}');
    }
    return configPath;
};

const getFileContent = (url) => {
    const fs = require('fs');
    let configPath = getConfigPath();
    let fileContent = fs.readFileSync(configPath) || '{}';
    try {
        fileContent = JSON.parse(fileContent);
    } catch(e) {
        fileContent = {};
    }
    return fileContent;
};

/*
 读取单个窗口的配置
 */
const readSettings = (url) => {
    let fileContent = getFileContent(url);
    let urlContent = fileContent[url] || {};
    return urlContent;
};

/*
 写入配置
 */
const saveSettings = (url, setting) => {
    const fs = require('fs');
    let configPath = getConfigPath();
    let utils = require('../../utils.js');
    let fileContent = getFileContent(url);
    let urlContent = readSettings(url);
    urlContent = utils.extend(urlContent, setting);
    fileContent[url] = urlContent;
    fileContent = JSON.stringify(fileContent);
    fs.writeFileSync(configPath, fileContent);
};

module.exports = {
    saveSettings,
    readSettings
};