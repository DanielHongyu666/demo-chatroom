(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;

components.getChatBanMessage = function(resolve, reject) {
    var options = {
        name: 'message-chat-ban',
        template: 'templates/message/ban.html',
        props: ['message'],
        computed: {
            banUser: function() {
                return this.message.content;
            },
            minute: function() {
                var duration = this.message.content.duration;
                return duration;
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);