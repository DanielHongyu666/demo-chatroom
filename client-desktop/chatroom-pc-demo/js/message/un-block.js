(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;

components.getChatUnBlockMessage = function(resolve, reject) {
    var options = {
        name: 'message-chat-un-block',
        template: 'templates/message/un-block.html',
        props: ['message'],
        computed: {
            blockUser: function() {
                return this.message.content;
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);