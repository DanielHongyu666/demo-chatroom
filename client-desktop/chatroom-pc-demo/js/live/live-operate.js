(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var chatroomList = RongIM.config.chatroomList;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;
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
            }
        },
        mounted: function() {
            
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
                userApi.endLive(chatRoomId, function(err) {
                    if (err) {
                        // TODO
                        return;
                    }
                });
                this.isStart = false;
            },
            quitChatRoom: function() {
                var userApi = dataModel.User;
                var chatRoomId = this.chatRoomId;
                userApi.quitChatRoom(chatRoomId, function(err) {
                    if (err) {
                        // TODO
                        return;
                    }
                    userApi.logout();
                    toLoginPage();
                });
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

function toLoginPage() {
    var im = RongIM.instance;
    im.$router.push({
        name: 'login'
    });
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);