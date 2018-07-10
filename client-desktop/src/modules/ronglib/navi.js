'use strict';
const request = require('request');
const utils = require('../../utils');
const fs = require('fs'); 
const path = require('path');

let naviPath = './navi-conf.json';
let naviConf = {};
try{
    naviConf = require(naviPath);
}catch(e){};

let writeFileSync = fs.writeFileSync;

let {stringFormat, prettyJSON} = utils;

naviPath = path.resolve(__dirname, naviPath);

let Cache = {
    set: (key, value) => {
        naviConf[key] = value;

        writeFileSync(naviPath, prettyJSON(naviConf));
    },
    get: (key) => {
        return naviConf[key];
    },
    clear: (key) => {
        delete naviConf[key];
        writeFileSync(naviPath, prettyJSON(naviConf));  
    }
};

/*
    let config = {
        // 必传
        userId: '',
        // 必传
        appkey: '',
        // 必传
        token: '',
        // 通过 RongIMClient.init 获得
        version: '2.87.1',
        // 公有云可选，私有云必传
        url: ''
    };
*/
let get = (config, callback) => {
    let {
        userId,
        appkey,
        token,
        version: v,
        url
    } = config;

    // 判断是否走缓存
    let navi = Cache.get(userId);
    if (navi) {
        let error = null;
        return callback(error, navi);
    }

    let urlTpl = 'http://{ip}/navi.json';
    url = url || '';

    url = url.split('//')[1] || 'nav.cn.ronghub.com';

    url = stringFormat(urlTpl, {
        ip: url
    });
    token = encodeURIComponent(token);
    let body = 'token={token}&v={v}';
    body = stringFormat(body, {
        token,
        v
    });
    request({
        url: url,
        method: 'POST',
        headers: {
            appId: appkey
        },
        body: body
    }, (error, resp, body) => {
        if (error) {
            callback(error);
            return;
        }
        body = JSON.parse(body);
        let isSuccess = (body.code == 200);
        if (isSuccess) {
            let tpl = '{server},{bs}';
            body.serverList = stringFormat(tpl, {
                server: body.server,
                bs: body.bs
            });
            Cache.set(userId, body);
            callback(error, body);
        }
        if (!isSuccess) {
            // body 存在错误信息
            error = body;
            callback(error);
        }
       
    });
};
/*
    let config = {
        //必须传
        userId: ''
    };
*/
let clear = (config) => {
    let {
        userId
    } = config;
    Cache.clear(userId);
};

module.exports = {
    get,
    clear
};