'use strict'
const {
    BrowserWindow
} = require('electron');

const RongConfig = require('../../config.js');
const mime = require('./lib/mime');
const config = require('./config');

const fs = require('fs');
const path = require('path');
const url = require('url');
const http = require('http');
const net = require('net');

const SSI = require('node-ssi');
// 需要进行 ssi 合并的文件类型
const SsiTypes = ['html', 'htmls', 'shtml', 'htm', 'php'];

const portRange = [10001, 65535];

let {
    port, open
} = config;
let rootDir = config.root;

// var isRootDirStat = (() => {
//     try {
//         return fs.statSync(rootDir);
//     } catch(e) {
//         return false;
//     }
// });

// if (isRootDirStat) {
    // rootDir = path.resolve(rootDir);
// } else {
    rootDir = path.join(__dirname, rootDir);
// }

const send = (res, opt) => {
    let {
        code, content, contentType
    } = opt;
    res.writeHeader(code, {
        'Content-Type': contentType
    });
    res.write(content);
    res.end();
};

const sendError = (res) => {
    return send(res, {
        code: 404,
        content: '<h1>404 Error</h1>'
    });
};

const sendResponse = (res, content, contentType) => {
    return send(res, {
        code: 200,
        content: content,
        contentType: contentType
    });
};

const getValidPort = (port, callback) => {
    callback = callback || (() => {});
    port = port || portRange[0];
    if (port > portRange[1]) {
        callback(true);
    }
    let server = net.createServer().listen(port);
    server.on('listening', () => {
        server.close();
        callback(null, port);
    });
    server.on('error', (err) => {
        console.log('error', err);
        if (err) {
            port++;
            getValidPort(port, callback);
        }
    });
};

const openServer = (port) => {
    open && http.createServer((req, res) => {
        let reqUrl = decodeURIComponent(req.url);
        let pathname = url.parse(reqUrl).pathname;
        let ext = path.extname(pathname);
        let contentType = mime[ext] || 'text/plain';
        let file = path.join(rootDir, pathname);
        fs.readFile(file, (err, data) => {
            if (err) {
                return sendError(res);
            }
            let extName = ext.substring(1);
            if (SsiTypes.indexOf(extName) === -1) {
                return sendResponse(res, data, contentType);
            }
            let ssi = new SSI({
                baseDir: rootDir,
                encoding: 'utf-8'
            });
            ssi.compile(data.toString(), {payload:{title: 'Index'}}, (err, content) => {
                if (err) {
                    return sendError(res);
                }
                return sendResponse(res, content, contentType);
            });
        });
    }).listen(port);
};

if (open) {
    let initPort = portRange[0];
    getValidPort(initPort, (err, validPort) => {
        if (err) {
            return console.log('所有端口都已被占用');
        }
        RongConfig.APP_HOST = 'http://localhost:' + validPort;
        openServer(validPort);
    });
}