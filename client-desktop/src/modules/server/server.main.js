'use strict'
const mime = require('./lib/mime'); 
const config = require('./config');

const fs = require('fs');
const path = require('path');
const url = require('url');
const http = require('http');

let { baseDir , props , types , port } = config; 

let sendRes = (res , data , contentType) => {
    res.writeHead(200 , {
        content : contentType
    });
    try{
        res.end(data)
    }catch(err){
        console.log(err , data);
    }
};

let getInstruction = (str , separator) => {
    // 获取指令 并去掉空字符
    return str.slice(0 , str.indexOf(separator)).replace(/\s/g, "");
};

let getVirtualPath = (str , separator) => {
    // 获取文件路径 并 清除前后 多余字符 "
    return str.slice(str.indexOf(separator) + 2 , -1);
};

/*****************指令方法*****************/
let virtual = (filePath) => {
    return fs.readFileSync(filePath).toString(); 
};

let getRoot = (filePath) => {
    // 获取读取文件路径父级文件夹
    return filePath.slice(0 , filePath.lastIndexOf('/'));
};

let instructionAll = {
    virtual
};

let rootPath = path.join(__dirname , baseDir); 
let ssi = (data) => {
    let reg = /<!--[ ]*#([a-z]+)([ ]+([a-z]+)="(.+?)")*[ ]*-->/g;
    data = data.replace( reg , ( ssiInstruction , include , ssiContent ) => {
            let instruction = getInstruction( ssiContent , '=' );
            if (props.indexOf(instruction) !== -1 ){
                //判断配置项中指令集合是否包含当 instruction 指令
                let virPath = getVirtualPath( ssiContent , '=' );
                let file = rootPath + '/' + virPath; 
                let filePath = path.join(rootPath , virPath); 
                let content = instructionAll[instruction]( filePath );

                if(reg.test(content)){  
                    /*
                        如果抓取文件中还存在指令 则递归遍历
                        更新rootPath路径
                    */
                    rootPath = getRoot(file);
                    content = ssi( content );
                }
                return content;
            }
        }
    );
    //递归执行结束之后 恢复默认路径
    rootPath = path.join(__dirname , baseDir); 
    return data;
};

http.createServer( (req , res) => {

    let reqUrl = decodeURIComponent(req.url);

	let urlObj = url.parse(reqUrl);

	let pathname = urlObj.pathname;

	let extension = path.extname(pathname);

	let contentType = mime[extension] || 'text/plain';

    let resFile = pathname;
    
    resFile = path.join( __dirname , baseDir , resFile);

    fs.readFile( resFile , (err , data) => {
        data = err || data;
        if( types.indexOf( extension.slice(1) ) !== -1 ){
            // 判断 types 集合中是否存在抓取文件后缀
            data = ssi( data.toString() );
        }
        sendRes(res , data , contentType);
    });

}).listen(port);