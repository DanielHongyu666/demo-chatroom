(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;

components.getChatUnBanMessage = function(resolve, reject) {
    var options = {
        name: 'message-chat-un-ban',
        template: 'templates/message/un-ban.html',
        props: ['message'],
        computed: {
            banUser: function() {
                return this.message.content;
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);