(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;

components.getMessageList = function(resolve, reject) {
    var options = {
        name: 'chat-messagelist',
        template: 'templates/chat/message-list.html',
        data: function() {
            return {
                messageList: []
            }
        },
        computed: {
            filterMessageList: function() {
                var chatRoomId = this.$route.params.chatRoomId;
                return this.messageList.filter(function(message) {
                    var isOffLineMessage = message.offLineMessage;
                    var isChatRoomMessage = utils.isChatRoomMessage(message);
                    var isSelfChatRoom = chatRoomId === message.targetId;
                    return isChatRoomMessage && isSelfChatRoom && !isOffLineMessage;
                });
            }
        },
        components: {
            ChatroomWelcome: components.getChatRoomWelcome,
            ChatroomUserQuit: components.getChatRoomUserQuit,
            ChatroomLike: components.getChatLikeMessage,
            ChatroomFollow: components.getChatFollowMessage,
            ChatroomUserBan: components.getChatBanMessage,
            ChatroomUserBlock: components.getChatBlockMessage,
            ChatroomUserUnBan: components.getChatUnBanMessage,
            ChatroomUserUnBlock: components.getChatUnBlockMessage,
            ChatroomStart: components.getChatStartLiveMessage,
            ChatroomEnd: components.getChatEndLiveMessage,
            TextMessage: components.getChatTextMessage
        },
        watch: {
            messageList: function(newVal) {
                if (newVal && newVal.length) {
                    var listEl = this.$el;
                    Vue.nextTick(function() {
                        utils.scrollToBottom(listEl);
                    });
                }
            }
        },
        mounted: function() {
            getMessageList(this);
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

function getMessageList(context) {
    dataModel.Message.getMessageList(function(err, messageList) {
        context.messageList = messageList;
    });
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);