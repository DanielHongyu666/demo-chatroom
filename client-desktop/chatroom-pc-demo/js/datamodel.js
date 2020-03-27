(function (RongIM, dependencies) {
    'use strict';
    var win = dependencies.win;
    var RongIMLib = dependencies.RongIMLib;
    var RongIMClient = dependencies.RongIMClient;
    var RongMessageTypes = dependencies.RongMessageTypes;
    var $ = dependencies.jQuery;
    var utils = RongIM.utils;
    var cache = utils.cache;
    var ObserverList = utils.ObserverList;
    var onlineUsers, followUsers, blockUsers, banUsers, upgradeUsers;
    var config = RongIM.config;

    var rongRTC;

    var RongRtc = {
        Room: {},
        Stream: {},
        Storage: {},
        StreamType: {}
    };
    var room, stream;
    var Cache = {
        auth: {},
        // 在线用户
        onlineUsers: [],
        // 禁言用户
        banUsers: [],
        // 封禁用户
        blockUsers: [],
        // 升级用户
        upgradeUsers: [],
        // 已关注用户
        followUsers: [],
        // 礼物
        gift: {},
        // 消息列表
        messageList: [],
        connectedTime: 0,
        liveStartTime: 0,
        clean: function () {
            Cache.auth = {};
            Cache.onlineUsers = [];
            Cache.banUsers = [];
            Cache.blockUsers = [];
            Cache.upgradeUsers = [];
            Cache.followUsers = [];
            Cache.gift = {};
            Cache.messageList = [];
            Cache.connectedTime = 0;
            Cache.liveStartTime = 0;
            setCacheUsers();
        }
    };

    setCacheUsers();

    var init = function (config) {
        var provider = RongIM.lib.getDataProvider();
        if (provider) {
            provider = new RongIMLib.VCDataProvider(provider);
        }
        RongIMClient.init(config.appkey, provider);
        //测试环境需要传递 navi
        // RongIMClient.init(config.appkey, null, { navi: config.navigation });
        setConnectionListener();
        setMessageListener();
        registerMessage();
        rtcInit();
        // Cache.auth = cache.get('auth');
    };

    // 连接状态
    var Status = {
        observerList: new ObserverList(),
        connect: connect,
        reconnect: reconnect,
        disconnect: function () {
            RongIMClient.getInstance().logout();
        },
        watch: function (listener) {
            Status.observerList.add(listener);
        },
        unwatch: function (listener) {
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
        // 加入 RTC 房间
        joinRtcRoom: joinRtcRoom,
        // 主播开始直播
        startLive: startLive,
        sendJoinLive: sendJoinLive,
        sendQuitLive: sendQuitLive,
        // 主播结束直播, 包含退出聊天室
        endLive: endLive,
        // 退出直播间
        quitChatRoom: quitChatRoom,
        // 退出 RTC
        quitRtcRoom: quitRtcRoom
    };
    var Stream = {
        // 发布资源
        getMediaStream: getMediaStream,
        subscribe: subscribe,
        updateToAnchor: updateToAnchor,
        setConfig:setConfig
    }

    // 在线用户操作
    var OnlineUser = {
        /*
            获取在线用户列表
         */
        getOnlineUsers: getOnlineUsers,
        // 将消息中的用户增加至 onlineUsers
        _add: function (message) {
            pushUser(message, onlineUsers, setOnlineUser);
        },
        // 将消息中的用户从 onlineUsers 中删除
        _remove: function (message) {
            removeUser(message, onlineUsers, removeOnlineUser);
        }
    };

    // 封禁用户
    var BlockUser = {
        getUsers: getBlockUsers,
        block: function (params, callback) {
            sendBlockMessage(params, callback, true);
        },
        unBlock: function (params, callback) {
            sendBlockMessage(params, callback, false);
        },
        _add: function (message) {
            pushUser(message, blockUsers, setBlockUser);
        },
        // 将消息中的用户从 onlineUsers 中删除
        _remove: function (message) {
            removeUser(message, blockUsers, removeBlockUser);
        }
    };

    // 禁言用户
    var BanUser = {
        getUsers: getBanUsers,
        ban: function (params, callback) {
            sendBanMessage(params, callback, true);
        },
        unBan: function (params, callback) {
            sendBanMessage(params, callback, false);
        },
        _add: function (message) {
            pushUser(message, banUsers, setBanUser);
        },
        _remove: function (message) {
            removeUser(message, banUsers, removeBanUser);
        }
    };

    // 升级用户
    var UpgradeUsers = {
        getUpgradeUsers: getUpgradeUsers,
        upgrade: function (params, callback) {
            sendUpgradeMessage(params, callback, true);
        },
        degrade: function (params, callback) {
            sendUpgradeMessage(params, callback, false);
        },
        _add: function (message) {
            pushUser(message, upgradeUsers, setUpgradeUsers);
        },
        _remove: function (message) {
            removeUser(message, upgradeUsers, removeUpgradeUsers);
            removeVideo(message);
        }
    }

    var Follow = {
        // 获取已关注用户
        getFollowUsers: getFollowUsers,
        _add: function (message) {
            pushUser(message, followUsers, setFollowUser);
        }
    };

    var Gift = {
        observerList: new ObserverList(),
        get: getGift,
        getName: getGiftName,
        _add: function (message) {
            setGift(message);
        },
        watch: function (listener) {
            Gift.observerList.add(listener);
        },
        unwatch: function (listener) {
            Gift.observerList.remove(listener);
        }
    };

    function notifyGift(message) {
        Gift.observerList.notify(message);
    }

    var Barrage = {
        observerList: new ObserverList(),
        watch: function (listener) {
            Barrage.observerList.add(listener);
        },
        unwatch: function (listener) {
            Barrage.observerList.remove(listener);
        }
    };

    function notifyBarrage(message) {
        Barrage.observerList.notify(message);
    }

    var Like = {
        observerList: new ObserverList(),
        watch: function (listener) {
            Like.observerList.add(listener);
        },
        unwatch: function (listener) {
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
        _push: function (message, callback) {
            var userId = message.senderUserId;
            // var user = getUserDetail(userId);
            message.user = message.content.user;
            Cache.messageList.push(message);
            callback && callback(null, message);
        },
        watch: function (listener) {
            Message.observerList.add(listener);
        },
        unwatch: function (listener) {
            Message.observerList.remove(listener);
        }
    };
    var messageObserver = Message.observerList;

    function rtcInit(liveRole) {
        // 初始化 RTC
        rongRTC = new RongRTC({
            // debug: true,
            RongIMLib: RongIMLib,
            mode: RongRTC.Mode.LIVE,
            //测试环境需要放开URL
            liveRole: utils.isAudience() ? RongRTC.ROLE.AUDIENCE : RongRTC.ROLE.ANCHOR,
            created: function () {
            },
            mounted: function () {
            },
            destroyed: function () {
            },
            error: function (error) {
            }
            // logger:function(log){
            //     console.info("logger ==>",JSON.stringify(log));
            // }
        });
        RongRtc.Room = rongRTC.Room;
        RongRtc.Stream = rongRTC.Stream;
        RongRtc.StreamType = rongRTC.StreamType
        // RongRtc.Storage = rongRTC.Storage;

        stream = new rongRTC.Stream({
            /* 成员已发布资源，此时可按需订阅 */
            published: function (user) {
                stream.subscribe(user).then((user) => {
                    let { id, stream: { tag, mediaStream } } = user;
                    let publishedUser = {};
                    //在在线用户中查找user信息
                    for (let i = 0; i < Cache.onlineUsers.length; i++) {
                        if (Cache.onlineUsers[i].id == id) {
                            publishedUser = Cache.onlineUsers[i];

                            let param = {};
                            param.content = {
                                id: id,
                                user: publishedUser
                            };
                            UpgradeUsers._add(param);
                            // UserInfos.push(Cache.onlineUsers[i]);
                        }
                    }

                    let div = document.createElement('div');
                    let span = document.createElement('span');
                    let node = document.createElement('VIDEO');

                    node.id = id;
                    node.onclick = function () {
                        let streamData = document.getElementsByClassName('rong-video')[0].srcObject;
                        let id = document.getElementsByClassName('rong-video')[0].id;
                        let name = document.getElementsByClassName('rong-video')[0].name || '自己';
                        let nodeName = this.parentElement.querySelector('span').innerHTML;
                        document.getElementsByClassName('rong-video')[0].srcObject = this.srcObject;
                        document.getElementsByClassName('rong-video')[0].id = this.id;
                        document.getElementsByClassName('rong-video')[0].name = nodeName;

                        this.srcObject = streamData;
                        this.id = id;
                        this.parentElement.querySelector('span').innerHTML = name
                    }
                    node.srcObject = mediaStream;
                    node.autoplay = true;

                    // 将 node 添加至页面或指定容器
                    div.className = "video-box";
                    span.innerHTML = publishedUser.name;
                    div.appendChild(node);
                    div.appendChild(span);
                    document.querySelector('.video-like-box').appendChild(div);

                    //广播消息通知所有主播同步用户消息  ChatroomSyncUserInfo
                    syncUserInfo(Cache.auth.chatRoomId, upgradeUsers);
                }, function (error) {
                    console.info(error)
                });
            },
            /* 成员已取消发布资源，此时需关闭流 */
            unpublished: function (user) {
                stream.unsubscribe(user);
            },
            /* 成员禁用摄像头时触发，此时需关闭视频流 */
            disabled: function (user) {
                stream.unsubscribe(user);
            },
            /* 成员启用摄像头时触发，此时需要重新打开视频流 */
            enabled: function (user) {
                stream.subscribe(user);
            },
            /* 成员禁用麦克风时触发 */
            muted: function (user) {

            },
            /* 成员禁用麦克风时触发，此时需要重新打开此成员声音 */
            unmuted: function (user) {
                stream.subscribe(user);
            }
        });
    }
    function setConnectionListener() {
        RongIMClient.setConnectionStatusListener({
            onChanged: function (status) {
                if(status == 3){
                    Status.reconnect();
                }
                statusObserver.notify(status);
            }
        });
    };

    function setMessageListener() {
        var messageCtrol = {
            ChatroomStart: function (message) {
                Message._push(message);
            },
            ChatroomEnd: function (message) {
                Message._push(message);
            },
            ChatroomWelcome: function (message) {
                OnlineUser._add(message);
                Message._push(message);
                console.info("用户加入：",message)
            },
            ChatroomUserQuit: function (message) {
                OnlineUser._remove(message);
                UpgradeUsers._remove(message);
                Message._push(message);
                console.info("用户离开：",message);
            },
            ChatroomFollow: function (message) {
                Message._push(message);
                Follow._add(message);
            },
            ChatroomGift: function (message) {
                Gift._add(message);
                notifyGift(message);
            },
            ChatroomBarrage: function (message) {
                notifyBarrage(message);
            },
            ChatroomLike: function (message) {
                Message._push(message);
                notifyLike(message);
            },
            ChatroomUserBan: function (message) {
                receiveBanUserMessage(message);
            },
            ChatroomUserUnBan: function (message) {
                receiveBanUserMessage(message);
            },
            ChatroomUserBlock: function (message) {
                receiveBlockUserMessage(message);
            },
            ChatroomUserUnBlock: function (message) {
                receiveBlockUserMessage(message);
            },
            TextMessage: function (message) {
                Message._push(message);
            },
            ChatroomLiveCmd: function (message) {
                Message._push(message);
            },
            ChatroomSyncUserInfo: function (message) {
                //处理接收的主播用户列表
                // Message._push(message)
            },
            otherMessage: function (message) {
            }
        };
        RongIMClient.setOnReceiveMessageListener({
            onReceived: function (message) {
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
            onSuccess: function (userId) {
                console.log('connect success');
                Cache.connectedTime = +new Date();
                callback(null, userId);
            },
            onTokenIncorrect: function () {
                callback('invalid-token');
            },
            onError: callback
        }, id);
    }

    function reconnect(callback) {
        callback = callback || $.noop;
        var events = {
            onSuccess: function(userId) {
                console.log('reconnect success. ' + userId);
                callback(userId);
            },
            onTokenIncorrect: function() {
                console.log('token 无效');
            },
            onError: function(errorCode) {
                reconnect(callback);
            }
        };
        var config = {
            auto: true,
            url: 'cdn.ronghub.com/RongIMLib-2.2.6.min.js?d=' + Date.now(),
            rate: [100, 1000, 1000, 1000, 1000, 1000]
        };
        RongIMClient.reconnect(events, config);
    }

    function registerMessage() {
        var chatroomMessages = RongMessageTypes.chatroom;
        RongIMClient.getInstance().registerMessageTypes(chatroomMessages);
    }

    function removeVideo(message) {
        var id = message.content.user.id;
        if (document.getElementById(id)) {
            if (document.getElementById(id).className == 'rong-video') {
                let streamData = document.getElementById(Cache.auth.id).srcObject;
                document.getElementsByClassName('rong-video')[0].srcObject = streamData;
                document.getElementById(Cache.auth.id).parentElement.remove();
                document.getElementsByClassName('rong-video')[0].id = Cache.auth.id;
            } else {
                document.getElementById(id).parentElement.remove();
            }
        }
    }

    /*
    加入聊天室
     */
    function joinChatRoom(chatRoomId, callback) {
        callback = callback || $.noop;
        // 不拉取最近消息
        var count = 0;
        RongIMClient.getInstance().joinChatRoom(chatRoomId, count, {
            onSuccess: function () {
                callback && callback();
            },
            onError: callback
        });
    }

    /**
     * 加入 RTC 房间（主播逻辑）
     * @param {string} chatRoomId 房间 ID
     * @param {object} auth 当前用户
     * @param {function} callback 回掉
     */
    function joinRtcRoom(chatRoomId, auth, callback) {
        callback = callback || $.noop;
        room = new RongRtc.Room({
            id: chatRoomId,
            joined: function (user) {
                // user.id 加入房间
                console.info("用户加入 RTC 房间：", user);
            },
            left: function (user) {
                // user.id 离开房间
                console.info("用户离开 RTC 房间：", user);
                if (document.getElementById(user.id).className == 'rong-video') {
                    let streamData = document.getElementById(Cache.auth.id).srcObject;
                    document.getElementsByClassName('rong-video')[0].srcObject = streamData;
                    document.getElementById(Cache.auth.id).parentElement.remove();
                    document.getElementsByClassName('rong-video')[0].id = Cache.auth.id;
                } else {
                    document.getElementById(user.id).parentElement.remove();
                }
            }
        });
        let user = {
            id: auth.id
        };
        return room.join(user).then(() => {
            console.log('join successfully');
        }, error => {
            console.log(error);
        });
    }

    // 获取本地视频资源
    function getMediaStream(callback) {
        callback = callback || $.noop;
        var users;
        
        return stream.get({
            video: { width: 640, height: 480 },
            audio: true
        }).then(function ({ mediaStream }) {
            users = {
                id: Cache.auth.id,
                mediaStream: mediaStream
            };
            let param = {};
            param.content = {
                id: Cache.auth.id,
                user: Cache.auth
            };
            upgradeUsers.push(Cache.auth);
            return publish(mediaStream);
        }).then(function () {
            callback(users);
        });
    }

    function subscribe(options) {
        options = options || {};
        return stream.subscribe(options);
    }

    function updateToAnchor() {
        return rongRTC.changeLiveRole(RongRTC.ROLE.ANCHOR);
    }

    function setConfig(options,callback){
        options = options || {};
        return stream.setMixConfig(options).then(res=>{
            return res;
        });
    }

    // 发布资源
    function publish(mediaStream) {
        let users = {
            id: Cache.auth.id,
            stream: {
                tag: 'RTC',
                type: RongRtc.StreamType.AUDIO_AND_VIDEO,
                // type: RongRtc.StreamType.AUDIO,
                mediaStream: mediaStream
            }
        };
        return stream.publish(users).then(result => {
            console.log('publish', result);
            let data = {
                "roomId": Cache.auth.chatRoomId,
                "roomName": Cache.auth.chatRoomName,
                "mcuUrl": result.liveUrl,
                "pubUserId": Cache.auth.id,
                "coverIndex": Cache.auth.random
            }
            $.ajax({
                url: config.appServer + "publish",
                type: 'POST',
                data: JSON.stringify(data),
                success: function (res) {
                    // res = JSON.parse(res);
                    if (res.code == 5) {
                        utils.messagebox({
                            message: '直播间已存在！',
                            submitText: '确定'
                        });
                        let user = {
                            id: Cache.auth.id,
                            stream: {
                                type: RongRtc.StreamType.AUDIO_AND_VIDEO
                            }
                        };
                        //加入失败后取消发布资源
                        stream.unpublish(user).then(result => {
                            console.log('取消推送成功', result);
                        }, error => {
                            console.log(error);
                        });
                        RongIM.instance.$router.push({
                            name: 'login'
                        });
                    }
                },
                error: function (data) {
                    console.log('err', data)
                },
            })
        }, error => {
            alert(error.msg);
            console.log(error);
        });
    }

    function getLiveRoomList(callbacks) {
        callbacks = callbacks || {};
        $.ajax({
            url: config.appServer + "query",
            type: 'POST',
            data: JSON.stringify({}),
            success: function (res) {
                // res = JSON.parse(res);
                callbacks.onSuccess && callbacks.onSuccess(res.roomList);
            },
            error: callbacks.onError
        })
    }

    function getUserDetail(userId) {
        var userList = utils.copyObj(RongIM.config.userList);
        var anchorList = utils.copyObj(RongIM.config.anchorList);
        userList = userList.concat(anchorList);
        var user = userList.filter(function (item) {
            return item.id === userId;
        });
        return user.length ? user[0] : {};
    }

    function sendTextMessage(targetId, content, callback) {
        var conversationType = RongIMLib.ConversationType.CHATROOM;
        var msg = new RongIMLib.TextMessage({
            content: content,
            user: Cache.auth
        });
        RongIMClient.getInstance().sendMessage(conversationType, targetId, msg, {
            onSuccess: function (msg) {
                Message._push(msg);
                callback(null, msg);
            },
            onError: callback
        });
    }

    function login(chat, callback, userName) {
        callback = callback || $.noop;
        var userId = new Date().getTime() + '';
        axios.post(config.appServer + "/user/get_token", { "id": userId })
            .then(res => {
                console.log('res=>', res);
                let loginUser = {
                    id: userId,
                    name: userName,
                    token: res.data.result.token,
                    portrait: random(),
                    chatRoomId: chat.id || chat.roomId,
                    chatRoomName: chat.name || chat.roomName
                }
                Cache.auth = loginUser;
                cache.set('auth', loginUser);
                callback(null, loginUser);
            }, error => {
                console.log(error);
            });

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
        Cache.gift[senderUserId].user = message.content.user;
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
     * 产生随机整数，包含下限值，包括上限值
     * @param {Number} lower 下限
     * @param {Number} upper 上限
     * @return {Number} 返回在下限到上限之间的一个随机整数
     */
    function random() {
        return Math.floor(Math.random() * 10);
    }
    /**
     * 根据消息存储 user 数组
     * @param  {object} message  消息
     * @param  {array} userList 存储的数组
     * @param  {function} setFuc   额外的存储方法, 为调用接口存储提供
     */
    function pushUser(message, userList, setFuc) {
        var userId = message.content.id;
        var name = message.content.user.name;
        var portrait = message.content.user.portrait;

        var user = {
            "id": userId,
            "name": name,
            "portrait": portrait,
        }
        user.message = message;
        var isExist = userList.filter(function (item) {
            return item.id === user.id;
        }).length > 0;
        var isSelf = user.id === Cache.auth.id;
        if (!isExist && !isSelf) {
            setFuc ? setFuc(user) : userList.push(user);
        }
        if(isExist){
            for(let i=0; i < userList.length; i++){
                if(userList[i].id === user.id){
                    utils.sliceArray(userList, userList[i]);
                    userList.push(user);
                }
            } 
        }
    }

    function removeUser(message, userList, removeFuc) {
        // var userId = message.content.id
        var user = message.content.user;
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


    function getUpgradeUsers(callback) {
        // 此处可调用接口获取数据
        callback(null, upgradeUsers);
    }
    function setUpgradeUsers(user, callback) {
        upgradeUsers.push(user);
        RongIM.instance.$emit('setConfig');
        callback && callback();
    }

    function removeUpgradeUsers(user, callback) {
        var isExist = upgradeUsers.filter(function (item) {
            return item.id === user.id;
        }).length > 0;
        if(isExist){
            utils.sliceArray(upgradeUsers, user);
            RongIM.instance.$emit('setConfig');
        }
        callback && callback();
    }


    function getBlockUsers(callback) {
        // 此处可调用接口获取数据
        callback(null, blockUsers);
    }

    function setBlockUser(user, callback) {
        let duration = user.message.content.duration;
        duration = parseInt(duration) * 60 * 1000;
        user.time = setTimeout(function () {
            utils.sliceArray(blockUsers, user);
        }, duration)
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
            id: params.user.id,
            duration: params.duration,
            user: params.user
        };
        var msg = new BlockMessage(content);
        var conversationType = RongIMLib.ConversationType.CHATROOM;
        var targetId = params.targetId;
        RongIMClient.getInstance().sendMessage(conversationType, targetId, msg, {
            onSuccess: function (message) {
                receiveBlockUserMessage(message);
                callback(null, message);
            },
            onError: callback
        });
    }
    /**
     * @param  {object}   params
     * params.cmdType 1：主播邀请观众上麦 2：观众接受上麦 3：观众拒绝上麦
     * params.roomId   房间ID
     * params.extra 扩展信息
     * params.targetId chatroomId
     */
    function sendUpgradeMessage(params, callback) {
        var RegisterMessage = RongIMClient.RegisterMessage;
        var UpgradeMessage = RegisterMessage.ChatroomLiveCmd;
        var content = {
            cmdType: params.cmdType,
            roomId: params.roomId,
            user: Cache.auth
        };
        var msg = new UpgradeMessage(content);
        var conversationType = RongIMLib.ConversationType.PRIVATE;
        var targetId = params.targetId;
        RongIMClient.getInstance().sendMessage(conversationType, targetId, msg, {
            onSuccess: function (message) {
                console.info('邀请上麦消息发送成功', message);
                callback();
            },
            onError: callback
        });
    }
    function getBanUsers(callback) {
        // 此处可调用接口获取数据
        callback(null, banUsers);
    }

    function setBanUser(user, callback) {
        let duration = user.message.content.duration;
        duration = parseInt(duration) * 60 * 1000;
        user.time = setTimeout(function () {
            utils.sliceArray(banUsers, user);
        }, duration)
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
            id: params.user.id,
            duration: params.duration,
            user: params.user
        };
        var msg = new BanMessage(content);
        var conversationType = RongIMLib.ConversationType.CHATROOM;
        var targetId = params.targetId;
        RongIMClient.getInstance().sendMessage(conversationType, targetId, msg, {
            onSuccess: function (message) {
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
            time: time,
            user: Cache.auth
        });
        Cache.liveStartTime = time;
        var chatroomType = RongIMLib.ConversationType.CHATROOM;
        RongIMClient.getInstance().sendMessage(chatroomType, chatRoomId, msg, {
            onSuccess: function (message) {
                Message._push(message);
                callback(null, message);
            },
            onError: callback
        });
    }

    function endLive(chatRoomId, callback) {
        var ChatroomUserQuit = RongIMClient.RegisterMessage.ChatroomUserQuit;
        // var duration = +new Date() - Cache.liveStartTime;
        // duration = duration / 1000 / 60;
        // duration = parseInt(duration) || 1;
        var msg = new ChatroomUserQuit({
            // duration: duration,
            user: Cache.auth
        });
        var chatroomType = RongIMLib.ConversationType.CHATROOM;
        RongIMClient.getInstance().sendMessage(chatroomType, chatRoomId, msg, {
            onSuccess: function (message) {
                Message._push(message);
                callback(null, message);
            },
            onError: callback
        });
    }

    function sendJoinLive(chatroomId, callback) {
        callback = callback || utils.noop;
        var ChatroomWelcome = RongIMClient.RegisterMessage.ChatroomWelcome;
        var msg = new ChatroomWelcome({
            id: Cache.auth.id,
            counts: 1,
            rank: 1,
            level: 1,
            user: {
                id: Cache.auth.id,
                name: Cache.auth.name,
                portrait: Cache.auth.portrait
            }
        });

        var im = RongIMClient.getInstance();
        var chatroomType = RongIMLib.ConversationType.CHATROOM;
        RongIMClient.getInstance().sendMessage(chatroomType, chatroomId, msg, {
            onSuccess: function (message) {
                console.log(message);
                Message._push(message);
                callback(null, message);
            },
            onError: callback
        });

    }

    function sendQuitLive(chatroomId, callback) {
        callback = callback || utils.noop;
        var ChatroomUserQuit = RongIMClient.RegisterMessage.ChatroomUserQuit;
        var msg = new ChatroomUserQuit({
            id: Cache.auth.id,
            user: {
                id: Cache.auth.id,
                name: Cache.auth.name,
                portrait: Cache.auth.portrait
            }
        });

        var im = RongIMClient.getInstance();
        var chatroomType = RongIMLib.ConversationType.CHATROOM;
        RongIMClient.getInstance().sendMessage(chatroomType, chatroomId, msg, {
            onSuccess: function (message) {
                console.log(message);
                Message._push(message);
                callback(null, message);
            },
            onError: callback
        });
    }

    function quitChatRoom(chatRoomId, callback) {
        RongIMClient.getInstance().quitChatRoom(chatRoomId, {
            onSuccess: function () {
                callback(null);
            },
            onError: callback
        });
        // quitRtcRoom();
    }
    function quitRtcRoom(callback) {
        room.leave().then(() => {
            console.log('leave successfully');
            callback(null);
        }, error => {
            callback(null);
            console.log(error);
        });
        let data = { "roomId": Cache.auth.chatRoomId };
        $.ajax({
            url: config.appServer + "unpublish",
            type: 'POST',
            data: JSON.stringify(data),
            success: function (data) {
                console.log(data)
            },
            error: function (data) {
                console.log('err', data)
            },
        })
    }
    function logout() {
        cache.remove('auth');
        Cache.clean();
        Status.disconnect();
        RongIM.instance.auth = null;
    }

    function syncUserInfo(chatRoomId, userList) {
        var ChatroomSyncUserInfo = RongIMClient.RegisterMessage.ChatroomSyncUserInfo;
        var msg = new ChatroomSyncUserInfo({
            userInfos: userList
        });
        var chatroomType = RongIMLib.ConversationType.CHATROOM;
        RongIMClient.getInstance().sendMessage(chatroomType, chatRoomId, msg, {
            onSuccess: function (message) {
                console.info('用户广播成功')
            },
            onError: function (message) {
                console.info('用户广播失败')
            },
        });
    }
    function setCacheUsers() {
        onlineUsers = Cache.onlineUsers;
        followUsers = Cache.followUsers;
        blockUsers = Cache.blockUsers;
        banUsers = Cache.banUsers;
        upgradeUsers = Cache.upgradeUsers;
    }
    RongIM.dataModel = {
        init: init,
        User: User,
        OnlineUser: OnlineUser,
        BlockUser: BlockUser,
        BanUser: BanUser,
        UpgradeUsers: UpgradeUsers,
        Follow: Follow,
        Gift: Gift,
        Barrage: Barrage,
        Like: Like,
        Status: Status,
        Message: Message,
        Cache: Cache,
        RongRtc: RongRtc,
        Stream: Stream,
        getLiveRoomList: getLiveRoomList
    };

})(RongIM, {
    win: window,
    RongIMLib: RongIMLib,
    jQuery: jQuery,
    RongIMClient: RongIMClient,
    RongMessageTypes: RongMessageTypes
});