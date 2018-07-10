(function(RongIM, dependencies) {
'use strict';
var $ = dependencies.jQuery;
var RongIMLib = dependencies.RongIMLib;
var RongIMEmoji = RongIMLib.RongIMEmoji;

var Queue = function() {
    this.isRunning = false;
    this.list = [];
};
Queue.prototype.add = function(fn) {
    var context = this;
    var run = function() {
        context.isRunning = true;
        var index = context.list.indexOf(run);
        context.list.splice(index, 1);
        fn(function() {
            context.isRunning = false;
            setTimeout(function() {
                context.run();
            }, 50)
        });
    };
    context.list.push(run);
};
Queue.prototype.run = function() {
    if (this.list.length && !this.isRunning) {
        var run = this.list[0];
        run && run();
    }
};

function textMessageFormat(content) {
    content = encodeHtmlStr(content);
    return RongIMEmoji.emojiToHTML(content, 13);
}

var cache = (function() {
    /*
    说明：
    1: JSON.stringfy --> set --> get --> JSON.parse
    2: data format well return as set`s
    3: undefined in array will be null after stringfy+parse
    4: NS --> namespace 缩写
    */
    var keyNS = 'rong-chatroom';

    function get(key) {
        /*
        legal data: "" [] {} null flase true

        illegal: undefined
            1: key not set
            2: key is cleared
            3: key removed
            4: wrong data format
        */
        key = keyNS + key;
        if (!isKeyExist(key)) {
            return;
        }
        //maybe keyNS could avoid conflict
        var val = localStorage.getItem(key) || sessionStorage.getItem(key);
        val = JSON.parse(val);
        //val format check
        if (val !== null && val.hasOwnProperty('type') && val.hasOwnProperty('data')) {
            return val.data;
        }
        /*
        how to return illegal data for im？
        */
        return;
    }
    //isPersistent
    function set(key, val, isTemp) {
        var store = localStorage;
        if (isTemp) {
            store = sessionStorage;
        }
        key = keyNS + key;
        var type = (typeof val);
        val = {
            data: val,
            type: type
        };
        store[key] = JSON.stringify(val);
    }

    function remove(key) {
        key = keyNS + key;
        localStorage.removeItem(key);
        sessionStorage.removeItem(key);
    }

    function isKeyExist(key) {
        //do not depend on value cause of ""和0
        return localStorage.hasOwnProperty(key) || sessionStorage.hasOwnProperty(key);
    }

    function setKeyNS(NS) {
        var isString = typeof NS === 'string';
        if (isString && NS !== '') {
            keyNS = NS;
        }
    }

    function onchange(callback) {
        callback = callback || $.noop;
        $(window).on('storage', function(e) {
            var event = e.originalEvent;
            if (isEmpty(event.key)) {
                return;
            }
            var key = event.key.slice(keyNS.length);
            var value = get(key);
            callback(key, value);
        });
    }
    return {
        setKeyNS: setKeyNS,
        get: get,
        set: set,
        remove: remove,
        onchange: onchange
    };
})();

function loadTemplate(template) {
    var promise;
    var pathRegex = new RegExp(/^([a-z_\-\s0-9\.\/]+)+\.html$/);
    var isTemplateUrl = pathRegex.test(template);
    if (isTemplateUrl) {
        promise = $.get(template);
    } else {
        var html = $(template).html();
        promise = $.Deferred().resolve(html).promise();
    }
    return promise;
}

// 异步组件
function asyncComponent(options, resolve, reject) {
    var promise = loadTemplate(options.template);
    promise.then(function(html) {
        options.mixins = options.mixins || [];
        var component = $.extend({}, options, {
            template: html
        });
        resolve(component);
    }).fail(function(xhr, status, error) {
        reject(error);
    });
}

function ObserverList() {
    var checkIndexOutBound = function(index, bound) {
        return index > -1 && index < bound;
    };
    this.observerList = [];

    this.add = function(observer, force) {
        if (force) {
            this.observerList.length = 0;
        }
        this.observerList.push(observer);
    };

    this.get = function(index) {
        if (checkIndexOutBound(index, this.observerList.length)) {
            return this.observerList[index];
        }
    };

    this.count = function() {
        return this.observerList.length;
    };

    this.removeAt = function(index) {
        checkIndexOutBound(index, this.observerList.length) && this.observerList.splice(index, 1);
    };

    this.remove = function(observer) {
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
    };

    this.notify = function(val){
        for (var i = 0, len = this.observerList.length; i < len; i++) {
            this.observerList[i](val);
        }
    };

    this.indexOf = function(observer, startIndex) {
        var i = startIndex || 0,
            len = this.observerList.length;
        while (i < len) {
            if (this.observerList[i] === observer) {
                return i;
            }
            i++;
        }
        return -1;
    };
}

function sliceArray(arr, item) {
    var sliceIndex = -1;
    arr.forEach(function(info, index) {
        if (info === item || info.id === item.id) {
            sliceIndex = index;
        }
    });
    if (sliceIndex >= 0) {
        arr.splice(sliceIndex, 1);
    }
}

function isChatRoomMessage(message) {
    var conversationType = message.conversationType;
    return conversationType === RongIMLib.ConversationType.CHATROOM;
}

function getTotalGift(allGift) {
    var count = 0;
    for (var userId in allGift) {
        var userGift = allGift[userId];
        for (var giftId in userGift) {
            var gift = userGift[giftId];
            count += gift.number;
        }
    }
    return count;
}

function encodeHtmlStr(str) {
    var replaceRule = [{
            symbol: '&',
            html: '&amp;'
        },
        //下述方法有问题,字符串中如有空格,会多加空格
        //white-space: pre-wrap; 能实现同样效果,并支持ie9, 故注释掉
        // {
        //     symbol: '[\\u0020]',
        //     html: '&nbsp;\u0020'
        // },
        {
            symbol: '[\\u0009]',
            html: '&nbsp;&nbsp;&nbsp;&nbsp;\u0020'
        }, {
            symbol: '<',
            html: '&lt;'
        }, {
            symbol: '>',
            html: '&gt;'
        }, {
            symbol: '\'',
            html: '&#39;'
        }, {
            symbol: '\\n\\r',
            html: '<br/>'
        }, {
            symbol: '\\r\\n',
            html: '<br/>'
        }, {
            symbol: '\\n',
            html: '<br/>'
        }
    ];
    for (var i = 0, len = replaceRule.length; i < len; i++) {
        var rule = replaceRule[i];
        var regExp = new RegExp(rule.symbol, 'g');
        str = str.replace(regExp, rule.html);
    }
    return str;
}

function addStyle(baseCss) {
    var style = document.createElement("style");
    style.setAttribute("type", "text/css");
    var head = document.getElementsByTagName('head')[0];
    head.appendChild(style);
    if (style.styleSheet) {
        style.styleSheet.cssText = baseCss;
    } else {
        head = document.createTextNode(baseCss);
        style.appendChild(head);
    }
    return head;
}

function getDom(html) {
    var div = document.createElement("div");
    div.innerHTML = html;
    return div.children[0];
}

function getRandomColor() {
    var r = Math.floor(Math.random() * 256);
    var g = Math.floor(Math.random() * 256);
    var b = Math.floor(Math.random() * 256);
    return 'rgb(' + r + ',' + g + ',' + b  +  ')';
}

function formatDateTime(timestamp) {    
    var date = new Date(timestamp);  
    var y = date.getFullYear();    
    var m = date.getMonth() + 1;    
    m = m < 10 ? ('0' + m) : m;    
    var d = date.getDate();    
    d = d < 10 ? ('0' + d) : d;    
    var h = date.getHours();  
    h = h < 10 ? ('0' + h) : h;  
    var minute = date.getMinutes();  
    var second = date.getSeconds();  
    minute = minute < 10 ? ('0' + minute) : minute;    
    second = second < 10 ? ('0' + second) : second;   
    return y + '-' + m + '-' + d + ' ' + h + ':' + minute + ':' + second;    
};
var BlockType = {
    Online: 0,
    Ban: 1,
    Block: 2
};

function copyObj(obj) {
    obj = JSON.stringify(obj);
    return JSON.parse(obj);
}

function scrollToBottom(el) {
    var totalHeight = 0;
    var children = el.children;
    for (var i = 0; i < children.length; i++) {
        var $childEl = $(children[i]);
        totalHeight += $childEl.outerHeight(true);
    }
    $(el).scrollTop(totalHeight);
}

RongIM.utils = {
    asyncComponent: asyncComponent,
    ObserverList: ObserverList,
    MD5: RongIMLib.RongUtil.MD5,
    status: RongIMLib.ConnectionStatus,
    sliceArray: sliceArray,
    textMessageFormat: textMessageFormat,
    isChatRoomMessage: isChatRoomMessage,
    getTotalGift: getTotalGift,
    formatDateTime: formatDateTime,
    BlockType: BlockType,
    scrollToBottom: scrollToBottom,
    copyObj: copyObj,
    getDom: getDom,
    addStyle: addStyle,
    Queue: Queue,
    cache: cache
};

})(RongIM, {
    jQuery: jQuery,
    RongIMLib: RongIMLib,
    Vue: Vue
})