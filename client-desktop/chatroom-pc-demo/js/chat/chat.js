(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var TabType = {
    Chat: 0,
    Gift: 1
};
var TabList = [
    { name: '聊天', type: TabType.Chat},
    { name: '礼物', type: TabType.Gift}
];

components.getChatList = function(resolve, reject) {
    var options = {
        name: 'chat-list',
        template: 'templates/chat/chat.html',
        data: function() {
            return {
                selectedType: TabType.Chat
            }
        },
        computed: {
            TabList: function() {
                return TabList;
            },
            selectedComponent: function() {
                return {
                    0: 'message',
                    1: 'gift'
                }[this.selectedType];
            }
        },
        components: {
            message: components.getChatMessage,
            gift: components.getChatGift
        },
        methods: {
            // 切换聊天和粉丝
            switchTab: function(type) {
                this.selectedType = type;
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);