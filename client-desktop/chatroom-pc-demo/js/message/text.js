(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;

components.getChatTextMessage = function(resolve, reject) {
    var options = {
        name: 'message-chat-text',
        template: 'templates/message/text.html',
        props: ['message'],
        computed: {
            content: function() {
                var content = this.message.content.content;
                return utils.textMessageFormat(content);
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);