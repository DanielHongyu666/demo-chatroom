(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;

components.getChatBlockMessage = function(resolve, reject) {
    var options = {
        name: 'message-chat-block',
        template: 'templates/message/block.html',
        props: ['message'],
        computed: {
            blockUser: function() {
                var userId = this.message.content.id;
                return dataModel.User.getDetail(userId);
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);