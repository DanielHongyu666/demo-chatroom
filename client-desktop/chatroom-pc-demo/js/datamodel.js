(function(RongIM, dependencies) {
'use strict';
var win = dependencies.win;
var RongIMLib = dependencies.RongIMLib;
var RongIMClient = dependencies.RongIMClient;
var RongMessageTypes = dependencies.RongMessageTypes;
var $ = dependencies.jQuery;
var utils = RongIM.utils;
var cache = utils.cache;
var ObserverList = utils.ObserverList;

var onlineUsers, followUsers, blockUsers, banUsers;

var Cache = {
    auth: {},
    // 在线用户
    onlineUsers: [],
    // 禁言用户
    banUsers: [],
    // 封禁用户
    blockUsers: [],
    // 已关注用户
    followUsers: [],
    // 礼物
    gift: {},
    // 消息列表
    messageList: [],
    connectedTime: 0,
    liveStartTime: 0,
    clean: function() {
        Cache.auth = {};
        Cache.onlineUsers = [];
        Cache.banUsers = [];
        Cache.blockUsers = [];
        Cache.followUsers = [];
        Cache.gift = {};
        Cache.messageList = [];
        Cache.connectedTime = 0;
        Cache.liveStartTime = 0;
        setCacheUsers();
    }
};

setCacheUsers();

var init = function(config) {
    var provider = RongIM.lib.getDataProvider();
    if(provider){
        provider = new RongIMLib.VCDataProvider(provider);
    }
    RongIMClient.init(config.appkey, provider);
    setConnectionListener();
    setMessageListener();
    registerMessage();
    // Cache.auth = cache.get('auth');
};

// 连接状态
var Status = {
    observerList: new ObserverList(),
    connect: connect,
    reconnect: reconnect,
    disconnect: function() {
        RongIMClient.getInstance().logout();
    },
    watch: function(listener) {
        Status.observerList.add(listener);
    },
    unwatch: function(listener) {
        Status.observerList.remove(listener);
    }
};
var statusObserver = Status.observerList;

// 用户操作
var User = {
    // 模拟用户登录, 此处使用假数据, 假数据参见: mock/anchor.js
    login: login,
    logout: logout,
    getDetail: getUserDetail,
    // 主播进入直播间
    joinChatRoom: joinChatRoom,
    // 主播开始直播
    startLive: startLive,
    // 主播结束直播, 包含退出聊天室
    endLive: endLive,
    // 退出直播间
    quitChatRoom: quitChatRoom
};

// 在线用户操作
var OnlineUser = {
    /*
        获取在线用户列表
     */
    getOnlineUsers: getOnlineUsers,
    // 将消息中的用户增加至 onlineUsers
    _add: function(message) {
        pushUser(message, onlineUsers, setOnlineUser);
    },
    // 将消息中的用户从 onlineUsers 中删除
    _remove: function(message) {
        removeUser(message, onlineUsers, removeOnlineUser);
    }
};

// 封禁用户
var BlockUser = {
    getUsers: getBlockUsers,
    block: function(params, callback) {
        sendBlockMessage(params, callback, true);
    },
    unBlock: function(params, callback) {
        sendBlockMessage(params, callback, false);
    },
    _add: function(message) {
        pushUser(message, blockUsers, setBlockUser);
    },
    // 将消息中的用户从 onlineUsers 中删除
    _remove: function(message) {
        removeUser(message, blockUsers, removeBlockUser);
    }
};

// 禁言用户
var BanUser = {
    getUsers: getBanUsers,
    ban: function(params, callback) {
        sendBanMessage(params, callback, true);
    },
    unBan: function(params, callback) {
        sendBanMessage(params, callback, false);
    },
    _add: function(message) {
        pushUser(message, banUsers, setBanUser);
    },
    _remove: function(message) {
        removeUser(message, banUsers, removeBanUser);
    }
};

var Follow = {
    // 获取已关注用户
    getFollowUsers: getFollowUsers,
    _add: function(message) {
        pushUser(message, followUsers, setFollowUser);
    }
};

var Gift = {
    observerList: new ObserverList(),
    get: getGift,
    getName: getGiftName,
    _add: function(message) {
        setGift(message);
    },
    watch: function(listener) {
        Gift.observerList.add(listener);
    },
    unwatch: function(listener) {
        Gift.observerList.remove(listener);
    }
};

function notifyGift(message) {
    Gift.observerList.notify(message);
}

var Barrage = {
    observerList: new ObserverList(),
    watch: function(listener) {
        Barrage.observerList.add(listener);
    },
    unwatch: function(listener) {
        Barrage.observerList.remove(listener);
    }
};

function notifyBarrage(message) {
    Barrage.observerList.notify(message);
}

var Like = {
    observerList: new ObserverList(),
    watch: function(listener) {
        Like.observerList.add(listener);
    },
    unwatch: function(listener) {
        Like.observerList.remove(listener);
    }
};

function notifyLike(message) {
    Like.observerList.notify(message);
}

// 消息
var Message = {
    sendTextMessage: sendTextMessage,
    observerList: new ObserverList(),
    getMessageList: getMessageList,
    _push: function(message, callback) {
        var userId = message.senderUserId;
        var user = getUserDetail(userId);
        message.user = user;
        Cache.messageList.push(message);
        callback && callback(null, message);
    },
    watch: function(listener) {
        Message.observerList.add(listener);
    },
    unwatch: function(listener) {
        Message.observerList.remove(listener);
    }
};
var messageObserver = Message.observerList;

function setConnectionListener() {
    RongIMClient.setConnectionStatusListener({
        onChanged: function(status) {
            statusObserver.notify(status);
        }
    });
};

function setMessageListener() {
    var messageCtrol = {
        ChatroomStart: function(message) {
            Message._push(message);
        },
        ChatroomEnd: function(message) {
            Message._push(message);
        },
        ChatroomWelcome: function(message) {
            OnlineUser._add(message);
            Message._push(message);
        },
        ChatroomUserQuit: function(message) {
            Message._push(message);
            OnlineUser._remove(message);
        },
        ChatroomFollow: function(message) {
            Message._push(message);
            Follow._add(message);
        },
        ChatroomGift: function(message) {
            Gift._add(message);
            notifyGift(message);
        },
        ChatroomBarrage: function(message) {
            notifyBarrage(message);
        },
        ChatroomLike: function(message) {
            Message._push(message);
            notifyLike(message);
        },
        ChatroomUserBan: function(message) {
            receiveBanUserMessage(message);
        },
        ChatroomUserUnBan: function(message) {
            receiveBanUserMessage(message);
        },
        ChatroomUserBlock: function(message) {
            receiveBlockUserMessage(message);
        },
        ChatroomUserUnBlock: function(message) {
            receiveBlockUserMessage(message);
        },
        TextMessage: function(message) {
            Message._push(message);
        },
        otherMessage: function(message) {
        }
    };
    RongIMClient.setOnReceiveMessageListener({
        onReceived: function(message) {
            message.offLineMessage = message.sentTime < Cache.connectedTime;
            if (message.offLineMessage) {
                // 暂不处理离线消息
                return;
            }
            var messageType = message.messageType;
            var presence = messageCtrol[messageType];
            presence ? presence(message) : messageCtrol['otherMessage'](message);
        }
    });
};

function connect(auth, deviceId, callback) {
    callback = callback || $.noop;
    var token = auth.token;
    var id = auth.id;
    if (deviceId) {
        var instance = RongIMClient.getInstance();
        instance.setDeviceInfo({ id: deviceId });
    }
    RongIMClient.connect(token, {
        onSuccess: function(userId) {
            console.log('connect success');
            Cache.connectedTime = +new Date();
            callback(null, userId);
        },
        onTokenIncorrect: function() {
            callback('invalid-token');
        },
        onError: callback
    }, id);
}

function reconnect(callback) {
    callback = callback || $.noop;
    RongIMClient.reconnect({
        onSuccess: function() {
            callback(null)
        },
        onError: callback
    });
}

function registerMessage() {
    var chatroomMessages = RongMessageTypes.chatroom;
    RongIMClient.getInstance().registerMessageTypes(chatroomMessages);
}

/*
获取登录用户信息
本 Demo 从 mock/user.js 中随机获取
 */
function getLoginUser(number) {
    var userList = RongIM.config.anchorList;
    // 假数据共 160 个, 20个一组组成8个聊天室
    userList = userList.slice((number - 1) * 20, number * 20);
    var index = Math.floor(Math.random() * 20);
    var user = userList[index];
    return user;
}

/*
加入聊天室
 */
function joinChatRoom(chatRoomId, callback) {
    callback = callback || $.noop;
    // 不拉取最近消息
    var count = 0;
    RongIMClient.getInstance().joinChatRoom(chatRoomId, count, {
        onSuccess: function() {
            callback && callback();
        },
        onError: callback
    });
}

function getUserDetail(userId) {
    var userList = utils.copyObj(RongIM.config.userList);
    var anchorList = utils.copyObj(RongIM.config.anchorList);
    userList = userList.concat(anchorList);
    var user = userList.filter(function(item) {
        return item.id === userId;
    });
    return user.length ? user[0] : {};
}

function sendTextMessage(targetId, content, callback) {
    var conversationType = RongIMLib.ConversationType.CHATROOM;
    var msg = new RongIMLib.TextMessage({
        content: content
    });
    RongIMClient.getInstance().sendMessage(conversationType, targetId, msg, {
        onSuccess: function(msg) {
            Message._push(msg);
            callback(null, msg);
        },
        onError: callback
    });
}

function login(chatRoomId, callback, number) {
    callback = callback || $.noop;
    var loginUser = getLoginUser(number);
    loginUser.chatRoomId = chatRoomId;
    Cache.auth = loginUser;
    cache.set('auth', loginUser);
    callback(null, loginUser);
}

function getOnlineUsers(callback) {
    // 此处可调用接口获取数据
    callback(null, onlineUsers);
}

function setOnlineUser(user, callback) {
    user.gift = {};
    onlineUsers.push(user);
}

function removeOnlineUser(user, callback) {
    utils.sliceArray(onlineUsers, user);
}

function getFollowUsers(callback) {
    callback(null, followUsers);
}

function setFollowUser(user, callback) {
    followUsers.push(user);
}

function setGift(message, callback) {
    var senderUserId = message.senderUserId;
    var giftId = message.content.id;
    var userGift = Cache.gift[senderUserId] = Cache.gift[senderUserId] || {};
    var gift = userGift[giftId] = userGift[giftId] || { number: 0 };
    gift.number += message.content.number;
}

function getGift(callback) {
    callback(null, Cache.gift);
}

function getMessageList(callback) {
    callback(null, Cache.messageList);
}

/**
 * 根据消息存储 user 数组
 * @param  {object} message  消息
 * @param  {array} userList 存储的数组
 * @param  {function} setFuc   额外的存储方法, 为调用接口存储提供
 */
function pushUser(message, userList, setFuc) {
    var userId = message.content.id
    var user = getUserDetail(userId);
    user.message = message;
    var isExist = userList.filter(function(item) {
        return item.id === user.id;
    }).length > 0;
    var isSelf = user.id === Cache.auth.id;
    if (!isExist && !isSelf) {
        setFuc ? setFuc(user) : userList.push(user);
    }
}

function removeUser(message, userList, removeFuc) {
    var userId = message.content.id
    var user = getUserDetail(userId);
    if (removeFuc) {
        removeFuc(user);
    } else {
        utils.sliceArray(userList, user);
    }
}

function getGiftName(id) {
    return {
        'GiftId_1': '蛋糕',
        'GiftId_2': '气球',
        'GiftId_3': '花儿',
        'GiftId_4': '项链',
        'GiftId_5': '戒指'
    }[id];
}

function getBlockUsers(callback) {
    // 此处可调用接口获取数据
    callback(null, blockUsers);
}

function setBlockUser(user, callback) {
    blockUsers.push(user);
    callback && callback();
}

function removeBlockUser(user, callback) {
    utils.sliceArray(blockUsers, user);
    callback && callback();
}

function receiveBlockUserMessage(message) {
    var isBlock = message.messageType === 'ChatroomUserBlock';
    var isUnBlock = message.messageType === 'ChatroomUserUnBlock';
    if (!isBlock && !isUnBlock) {
        return;
    }
    if (isBlock) {
        BlockUser._add(message);
        OnlineUser._remove(message);
    } else {
        BlockUser._remove(message);
    }
    Message._push(message);
}

/**
 * @param  {object}   params
 * params.targetId chatroomId
 * params.id   封禁的 userId
 * params.duration 封禁时长
 */
function sendBlockMessage(params, callback, isBlock) {
    var RegisterMessage = RongIMClient.RegisterMessage;
    var BlockMessage = isBlock ? RegisterMessage.ChatroomUserBlock : RegisterMessage.ChatroomUserUnBlock;
    var content = {
        id: params.id,
        duration: params.duration
    };
    var msg = new BlockMessage(content);
    var conversationType = RongIMLib.ConversationType.CHATROOM;
    var targetId = params.targetId;
    RongIMClient.getInstance().sendMessage(conversationType, targetId, msg, {
        onSuccess: function(message) {
            receiveBlockUserMessage(message);
            callback(null, message);
        },
        onError: callback
    });
}

function getBanUsers(callback) {
    // 此处可调用接口获取数据
    callback(null, banUsers);
}

function setBanUser(user, callback) {
    banUsers.push(user);
    callback && callback();
}

function removeBanUser(user, callback) {
    utils.sliceArray(banUsers, user);
    callback && callback();
}

function receiveBanUserMessage(message) {
    var isBan = message.messageType === 'ChatroomUserBan';
    var isUnBan = message.messageType === 'ChatroomUserUnBan';
    if (!isBan && !isUnBan) {
        return;
    }
    isBan ? BanUser._add(message) : BanUser._remove(message);
    Message._push(message);
}

/**
 * @param  {object}   params
 * params.targetId chatroomId
 * params.id   封禁的 userId
 * params.duration 封禁时长
 */
function sendBanMessage(params, callback, isBan) {
    var RegisterMessage = RongIMClient.RegisterMessage;
    var BanMessage = isBan ? RegisterMessage.ChatroomUserBan : RegisterMessage.ChatroomUserUnBan;
    var content = {
        id: params.id,
        duration: params.duration
    };
    var msg = new BanMessage(content);
    var conversationType = RongIMLib.ConversationType.CHATROOM;
    var targetId = params.targetId;
    RongIMClient.getInstance().sendMessage(conversationType, targetId, msg, {
        onSuccess: function(message) {
            receiveBanUserMessage(message);
            callback(null, message);
        },
        onError: callback
    });
}

function startLive(chatRoomId, callback) {
    var ChatroomStart = RongIMClient.RegisterMessage.ChatroomStart;
    var time = +new Date();
    var msg = new ChatroomStart({
        time: time
    });
    Cache.liveStartTime = time;
    var chatroomType = RongIMLib.ConversationType.CHATROOM;
    RongIMClient.getInstance().sendMessage(chatroomType, chatRoomId, msg, {
        onSuccess: function(message) {
            Message._push(message);
            callback(null, message);
        },
        onError: callback
    });
}

function endLive(chatRoomId, callback) {
    var ChatroomEnd = RongIMClient.RegisterMessage.ChatroomEnd;
    var duration = +new Date() - Cache.liveStartTime;
    duration = duration / 1000 / 60;
    duration = parseInt(duration) || 1;
    var msg = new ChatroomEnd({
        duration: duration
    });
    var chatroomType = RongIMLib.ConversationType.CHATROOM;
    RongIMClient.getInstance().sendMessage(chatroomType, chatRoomId, msg, {
        onSuccess: function(message) {
            Message._push(message);
            callback(null, message);
        },
        onError: callback
    });
}

function quitChatRoom(chatRoomId, callback) {
    RongIMClient.getInstance().quitChatRoom(chatRoomId, {
        onSuccess: function() {
            callback(null);
        },
        onError: callback
    });
}

function logout() {
    cache.remove('auth');
    Cache.clean();
    Status.disconnect();
    RongIM.instance.auth = null;
}

function setCacheUsers() {
    onlineUsers = Cache.onlineUsers;
    followUsers = Cache.followUsers;
    blockUsers = Cache.blockUsers;
    banUsers = Cache.banUsers;
}

RongIM.dataModel = {
    init: init,
    User: User,
    OnlineUser: OnlineUser,
    BlockUser: BlockUser,
    BanUser: BanUser,
    Follow: Follow,
    Gift: Gift,
    Barrage: Barrage,
    Like: Like,
    Status: Status,
    Message: Message,
    Cache: Cache
};

})(RongIM, {
    win: window,
    RongIMLib: RongIMLib,
    jQuery: jQuery,
    RongIMClient: RongIMClient,
    RongMessageTypes: RongMessageTypes
});