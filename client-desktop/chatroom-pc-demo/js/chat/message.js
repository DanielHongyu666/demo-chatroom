(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
components.getChatMessage = function(resolve, reject) {
    var options = {
        name: 'chat-message',
        template: 'templates/chat/message.html',
        data: function() {
            return {

            };
        },
        computed: {
            
        },
        components: {
            messageList: components.getMessageList,
            messageInput: components.getMessageInput
        },
        methods: {
            
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);