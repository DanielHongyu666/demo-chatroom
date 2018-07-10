const {
    remote
} = require('electron');
const fs = require('fs');
const path = require('path')
const cachePath = remote.app.getPath('userData');
const utils = remote.require('./utils');

// 保证缓存路径存在
let initDir = function(basepath, dirname) {
    let destDir = dirname ? path.join(basepath, dirname) : basepath;
    if(!utils.dirExists(destDir)){
        utils.makeDir(destDir);
    }
    return destDir;
}

// 保证缓存所用文件存在
let initFile = function(filepath, content) {
    if(!utils.fileExists(filepath)){
        fs.writeFileSync(filepath, content);  
    }
}

// 分片下载/上传缓存区
let sliceBase = initDir(cachePath, 'slice');

// 分片下载
let downloadBase = initDir(sliceBase, 'download');
let download = {
    tmpPath: path.join(downloadBase, 'tmp-files'),
    rangeConf: path.join(downloadBase, 'range.json')
}
initDir(download.tmpPath);
initFile(download.rangeConf, '{}');

// 分片上传
let uploadBase = initDir(sliceBase, 'upload');
let upload = {
    tmpPath: path.join(uploadBase, 'tmp-files'),
    rangeConf: path.join(uploadBase, 'range.json')
}
initDir(upload.tmpPath);
initFile(upload.rangeConf, '{}');

// 图片/小视频缓存,暂时未用
let mediaCacheBase = path.join(cachePath, 'rongCache');
let mediaCacheTmp = '{appKey}/{userId}';

module.exports = {
    download,
    upload,
    mediaCache: {
        base: mediaCacheBase,
        tmp: mediaCacheTmp
    }
};