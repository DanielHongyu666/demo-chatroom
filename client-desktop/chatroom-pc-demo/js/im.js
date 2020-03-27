(function (RongIM, dependencies, components, RongDesktop) {
    'use strict';
    var Vue = dependencies.Vue;
    var VueRouter = dependencies.VueRouter;
    var $ = dependencies.jQuery;
    var utils = RongIM.utils;
    var routes = RongIM.routes;
    var dataModel = RongIM.dataModel;
    var RongRtc = dataModel.RongRtc;
    var Cache = dataModel.Cache;
    var Window = RongDesktop.require('Window');
    var pcWin = Window.current;
    var IMLib = RongIM.Lib;

    function init(config) {
        var im = new Vue({
            el: config.el,
            router: getRouter(),
            data: {
                auth: null,
                isMaxWindow: false,
                platform: RongIM.system.platform,
                isAudience: utils.isAudience()
            },
            watch: {
                auth: function (newVal) {
                    if (newVal) {
                        watchConnectionStatus(dataModel.Status, im);
                    }
                    var router = im.$router;
                    authChanged(router, newVal);
                }
            },
            mounted: function () {
                this.isMaxWindow = pcWin ? pcWin.isMax() : null;
                var statusApi = dataModel.Status;
                watchConnectionStatus(statusApi, this);
            },
            methods: {
                min: function () {
                    pcWin.min();
                },
                max: function () {
                    pcWin.max();
                    this.isMaxWindow = true;
                },
                restore: function () {
                    pcWin.restore();
                    this.isMaxWindow = false;
                },
                close: function () {
                    pcWin.close();
                }
            }
        });
        dataModel.init(config);
        im.dataModel = dataModel;
        im.auth = Cache.auth;
        RongIM.instance = im;
    }

    function authChanged(router, auth) {
        if (auth && auth.id) {
            var chatRoomId = auth.chatRoomId;
            connect(auth, function () {
                var im = RongIM.instance;
                router.push({
                    name: 'chatroom',
                    params: {
                        chatRoomId: chatRoomId
                    }
                });
                joinChatRoom(chatRoomId);
                !im.isAudience && joinRtcRoom(chatRoomId, auth);
            });
        } else {
            toLogin(router);
        }
    }

    function toLogin(router) {
        router.push({
            name: 'login'
        });
    }

    function connect(auth, callback) {
        var deviceId = getDeviceId();
        dataModel.Status.connect(auth, deviceId, function (err) {
            if (err) {
                // TODO 报错提示
                return;
            }
            callback();
        });
    }

    function joinChatRoom(chatRoomId) {
        dataModel.User.joinChatRoom(chatRoomId, function (err) {
            if (err) {
                // TODO 报错提示
                return;
            }
        });
    }
    function joinRtcRoom(chatRoomId, user) {
        dataModel.User.joinRtcRoom(chatRoomId, user, function (err) {
            if (err) {
                // TODO 报错提示
                return;
            }
        });
    }

    function getRouter() {
        var router = new VueRouter({
            linkActiveClass: routes.linkActiveClass,
            routes: routes.maps
        });
        return router;
    }

    function watchConnectionStatus(statusApi, im) {
        statusApi.unwatch(im.watchStatus);
        var kickedStatus = utils.status['KICKED_OFFLINE_BY_OTHER_CLIENT'];
        var blockedStatus = utils.status['USER_BLOCKED'];
        var errMap = {
            'logout-by-otherclient': 'logout-by-otherclient'
        };
        errMap[kickedStatus] = 'kicked-offline-by-otherclient';
        errMap[blockedStatus] = 'user-be-blocked';
        im.watchStatus = function (status) {
            console.log('connect status change', status);
            if (errMap[status]) {
                // TODO 报错提示
                toLogin(im.$router);
                statusApi.unwatch(im.watchStatus);
                im.dataModel.User.logout();
                return alert('该账号已在其他设备登录');
            }
        };
        statusApi.watch(im.watchStatus);
    }

    /*
    获取设备Id
     */
    function getDeviceId() {
        var deviceId = RongIM.system.getDeviceId();
        var config = RongIM.config;
        if (deviceId) {
            deviceId = deviceId + config.appkey;
            deviceId = utils.MD5(deviceId);
            if (deviceId.length === 32) {
                deviceId = deviceId.substr(5, 22);
                console.log('deviceId', deviceId);
                return deviceId;
            }
        }
        return '';
    }

    RongIM.init = init;

})(RongIM, {
    jQuery: jQuery,
    Vue: Vue,
    VueRouter: VueRouter,
    win: window
}, RongIM.components, RongDesktop);