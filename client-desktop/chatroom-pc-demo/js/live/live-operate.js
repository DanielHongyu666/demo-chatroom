(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
components.getLiveOperate = function(resolve, reject) {
    var options = {
        name: 'live-operate',
        template: 'templates/live/live-operate.html',
        data: function() {
            return {
                isStart: false
            }
        },
        computed: {
            chatRoomId: function() {
                return this.$route.params.chatRoomId;
            },
            isAudience: function () {
                return RongIM.instance.isAudience;
            }
        },
        mounted: function() {
            if (utils.isAudience()) {
                var chatRoomId = this.chatRoomId;
                dataModel.User.sendJoinLive(chatRoomId);
            } else {
                this.startLive();
            }
        },
        methods: {
            startLive: function() {
                var chatRoomId = this.chatRoomId;
                dataModel.User.startLive(chatRoomId, function(err) {
                });
                this.isStart = true;
            },
            endLive: function() {
                var userApi = dataModel.User;
                var chatRoomId = this.chatRoomId;
                var context = this;
                if (utils.isAudience()) {
                    dataModel.User.sendQuitLive(chatRoomId, function () {
                        window.location.reload(); 
                    });
                } else {
                    userApi.endLive(chatRoomId, function (err) {
                        if (err) {
                            // TODO
                            return;
                        }
                        context.quitChatRoom();
                    });
                }
            },
            quitChatRoom: function() {
                var userApi = dataModel.User;
                var chatRoomId = this.chatRoomId;
                var context = this;
                userApi.quitRtcRoom(function(){
                    userApi.quitChatRoom(chatRoomId, function(err) {
                        if (err) {
                            // TODO
                            return;
                        }
                        userApi.logout();
                        toLoginPage();
                        context.isStart = false;
                    });
                });
            },
            // 升级为主播
            updateToAnchor: function () {
                dataModel.Stream.updateToAnchor().then(function () {
                    var auth = RongIM.instance.auth;
                    return dataModel.User.joinRtcRoom(auth.chatRoomId, auth);
                }).then(function () {
                    dataModel.Stream.getMediaStream(function(user){
                        var isSelf = true;
                        appendVideoWithStream(user, isSelf);
                    });
                });
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};
function createVideo(stream) {
    var video = document.createElement('video');
    video.srcObject = stream.mediaStream;
    video.autoplay = true;
    video.id = stream.id;
    video.name = '自己';
    video.className = 'rong-video';
    return video;
};
function appendVideoWithStream(stream, isSelf) {
    let video = createVideo(stream);
    if (isSelf) {
        video.muted = true;
    }
    document.querySelector('.live-content video').remove();
    document.querySelector('.live-content').appendChild(video);
}
function toLoginPage() {
    var im = RongIM.instance;
    im.$router.push({
        name: 'login'
    });
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);