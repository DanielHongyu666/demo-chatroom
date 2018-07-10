'use strict'
const path = require('path')
const fs = require('fs')
const decompress = require('decompress')
const decompressUnzip = require('decompress-unzip')
const underscore = require('underscore');
const exec = require('child_process').exec;

exports.getNameByUrl = function(field, url) {
    var href = url ? url : window.location.href;
    var reg = new RegExp('[?&]' + field + '=([^&#]*)', 'i');
    var string = reg.exec(href);
    return string ? decodeURIComponent(decodeURIComponent(string[1])) : null;
};
exports.getDirByUrl = function(url) {
    var re = /([\w\d_-]*)\.?[^\\\/]*$/i;
    return url.match(re)[1];
};
exports.getSavePath = function(url) {
    url = decodeURIComponent(url);
    var fileName = this.getNameByUrl('attname', url) || '';
    var savePath = path.join(this.getDirByUrl(url), fileName);
    return savePath;
};

var stringFormat = function(temp, data, regexp) {
    if (!(Object.prototype.toString.call(data) === "[object Array]")) data = [data];
    var ret = [];
    for (var i = 0, j = data.length; i < j; i++) {
        ret.push(replaceAction(data[i]));
    }
    return ret.join("");

    function replaceAction(object) {
        return temp.replace(regexp || (/{([^}]+)}/g), function(match, name) {
            if (match.charAt(0) == '\\') return match.slice(1);
            return (object[name] != undefined) ? object[name] : '{' + name + '}';
        });
    }
};
exports.stringFormat = stringFormat;

var tplEngine = (temp, data, regexp) => {
    if (!(Object.prototype.toString.call(data) === "[object Array]")) data = [data];
    var ret = [];
    for (var i = 0, j = data.length; i < j; i++) {
        ret.push(replaceAction(data[i]));
    }
    return ret.join("");

    function replaceAction(object) {
        return temp.replace(regexp || (/{([^}]+)}/g), function(match, name) {
            if (match.charAt(0) == '\\') return match.slice(1);
            return (object[name] != undefined) ? object[name] : '{' + name + '}';
        });
    }
};
exports.tplEngine = tplEngine;

exports.platform = {
    win32: /^win/i.test(process.platform),
    darwin: /^darwin/i.test(process.platform),
    linux: /^linux/i.test(process.platform)
};
exports.handleError = function(error, extra, isShowError) {
    console.log('err', error, extra);
};

exports.fileExists = function(filePath) {
    try {
        return fs.statSync(filePath)
            .isFile()
    } catch (err) {
        return false
    }
};

exports.dirExists = function(filePath) {
    try {
        return fs.statSync(filePath)
            .isDirectory()
    } catch (err) {
        return false
    }
};

exports.makeDir = function(dir) {
    try {
        fs.mkdirSync(dir)
        return true
    } catch (err) {
        return false
    }
};

exports.unzip = function(params){
    var origin = params.origin;
    var dist = params.dist;

    return decompress(origin, dist, {
        plugins: [
            decompressUnzip()
        ]
    });
};

exports.getModulePath = (mod) => {
    var platform = process.platform;
    var version = mod.version;
    var tpl = mod.path;
    return stringFormat(tpl, {platform, version});
};

exports.copyEverything = (params, callback) => {
    var isExists = fs.existsSync(params.dst);

    if (isExists) {
        callback();
        return;
    }

    var getShell = () => {
        var tpl = '{shell} {src} {dst}';
        var isWin32 = (process.platform == 'win32');
        params.shell = isWin32 ? 'copy' : 'cp -r';
        return stringFormat(tpl, params);
    };

    var sh = getShell();
    exec(sh,function (error, stdout, stderr) {
        if (error !== null) {
          console.log('exec error: ' + error);
        }
        callback();
    });
};

exports.moduleRename = (params) => {
    var oriname = params.oriname;
    var newname = params.newname;
    var url = params.url;
    var platform = process.platform;
    url = stringFormat(url, {platform});

    var getPath = (name) => {
        return path.resolve(__dirname, url, name);
    };
    var oriPath = getPath(oriname);
    var newPath = getPath(newname);
    if (fs.existsSync(oriPath)) {
        fs.writeFileSync(newPath, fs.readFileSync(oriPath));
    }
};

function sizeBase64(base64, type){
  var str = base64;
  var equalIndex = str.indexOf('=');
  if(equalIndex > 0){
      str = str.substring(0, equalIndex);
  }
  var strLength = str.length;
  var size = parseInt(strLength-(strLength / 8) * 2);
  return size;
}

exports.splitBase64 = function(dataurl) {
  var arr = dataurl.split(',');
  var mime = arr[0].match(/:(.*?);/)[1];
  var size = sizeBase64(arr[1]);
  return {dataURL: dataurl, base64: arr[1], type: mime, size: size};
};

exports.deleteDir = function(path) {  
    var files = [];  
    if(fs.existsSync(path)) {  
        files = fs.readdirSync(path);  
        files.forEach(function(file, index) {  
            var curPath = path + "/" + file;  
            if(fs.statSync(curPath).isDirectory()) { // recurse  
                deleteDir(curPath);  
            } else { // delete file  
                fs.unlinkSync(curPath);  
            }  
        });  
        fs.rmdirSync(path);  
    }  
};

exports.deleteFile = function(path) {
    if(this.fileExists(path)){
        fs.unlinkSync(path);  
    }
};

exports.extend = function() {
    if (arguments.length === 0) {
        return;
    }
    var obj = arguments[0];
    var newObj = {};
    for (var key in obj) {
        newObj[key] = obj[key];
    }
    for (var i = 1, len = arguments.length; i < len; i ++) {
        var other = arguments[i];
        for (var item in other) {
            newObj[item] = other[item];
        }
    }
    return newObj;
};

exports.getQueryParams = function(url) {
    if (typeof url !== 'string') {
        return {};
    }
    let RE_URL = /([^&=]+?)(?=(=|&|$|#))=([^&$#]*)?/gi;
    let RE_HTTP = /(https?):\/\//;
    let RE_RCE = /(rce:\/\/)/;
    var ma = null;
    var params = {};
    var k, v;
    if (url.match(RE_HTTP)) {
        url = url.slice(url.indexOf('?') + 1);
    } else if (url.match(RE_RCE)) {
        url = url.slice(url.indexOf('rce://') + 6);
    } else {
        return {};
    }
    while((ma = RE_URL.exec(url)) !== null) {
        k = ma[1];
        v = ma[3];
        if (!params[k]) {
            params[k] = v;
        }
    }
    return params;
}

/*
    template : 'yyyy年MM月dd日 hh:mm:ss' , 
    date : '2018/1/1' 默认当前时间
*/
exports.dateFormat = (date, template) => {
    template = template || 'yyyy-MM-dd';
    date = date ? new Date(date) : new Date();
    let year = date.getFullYear();
    let month = date.getMonth() + 1;
    let day = date.getDate();
    let hour = date.getHours();
    let minute = date.getMinutes();
    let second = date.getSeconds();
    let setTemp = (reg, content) => {
        template = template.replace(reg, () => {
            return content < 10 ? '0' + content : content;
        });
    };
    template = template.replace(/yyyy/, year);
    setTemp(/MM/, month);
    setTemp(/dd/, day);
    setTemp(/hh/, hour);
    setTemp(/mm/, minute);
    setTemp(/ss/, second);
    return template;
};

exports.prettyJSON = (content) => {
    return JSON.stringify(content, null, 4)
};

const checkIndexOutBound = (index, bound) => {
    return index > -1 && index < bound;
};
class ObserverList {
    constructor() {
        this.observerList = [];
    }
    add(observer, force) {
        if (force) {
            this.observerList.length = 0;
        }
        this.observerList.push(observer);
    }
    get(index) {
        if (checkIndexOutBound(index, this.observerList.length)) {
            return this.observerList[index];
        }
    }
    count() {
        return this.observerList.length;
    }
    removeAt(index) {
        checkIndexOutBound(index, this.observerList.length) && this.observerList.splice(index, 1);
    }
    remove(observer) {
        if(!observer) {
            this.observerList.length = 0;
            return;
        }
        var observerList = Object.prototype.toString.call(observer) === '[object Function]' ? [observer] : observer;
        for (var i = 0, len = this.observerList.length; i < len; i++) {
            for (var j = 0; j < observerList.length; j++) {
                if (this.observerList[i] === observerList[j]) {
                    this.removeAt(i);
                    break;
                }
            }
        }
    }
    notify(val) {
        for (var i = 0, len = this.observerList.length; i < len; i++) {
            this.observerList[i](val);
        }
    }
    indexOf(observer, startIndex) {
        var i = startIndex || 0,
            len = this.observerList.length;
        while (i < len) {
            if (this.observerList[i] === observer) {
                return i;
            }
            i++;
        }
        return -1;
    }
}

exports.ObserverList = ObserverList;

exports._ = underscore;