(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;

components.getChatStartLiveMessage = function(resolve, reject) {
    var options = {
        name: 'message-chat-start-live',
        template: 'templates/message/start-live.html',
        props: ['message'],
        computed: {
            time: function() {
                var time = this.message.content.time;
                return utils.formatDateTime(time);
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);