(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var messageApi = dataModel.Message;
var im;
components.getMessageInput = function(resolve, reject) {
    var options = {
        name: 'chat-messageinput',
        template: 'templates/chat/message-input.html',
        data: function() {
            return {
                content: '',
                isShowEmojiPanel: false
            }
        },
        components: {
            emojiPanel: components.getEmojiPanel
        },
        methods: {
            sendText: sendTextMessage,
            showEmojiPanel: function() {
                this.isShowEmojiPanel = !this.isShowEmojiPanel;
            },
            hideEmojiPanel: function() {
                this.isShowEmojiPanel = false;
            },
            setEmoji: function(emoji) {
                this.content += emoji;
                this.isShowEmojiPanel = false;
            },
            enter: function(event) {
                var e = event || window.event || arguments.callee.caller.arguments[0];
                if (e.keyCode == 13 && !e.shiftKey && this.content) {
                    this.sendText();
                }
            }
        },
        mounted: function() {
            im = RongIM.instance;
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

function sendTextMessage() {
    var inputContext = this;
    var targetId = im.$route.params.chatRoomId;
    var content = inputContext.content;
    messageApi.sendTextMessage(targetId, content, function(err) {
        if (err) {
            // TODO
            console.log('发送失败');
        }
        inputContext.content = '';
    });
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);