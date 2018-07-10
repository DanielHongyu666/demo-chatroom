(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;

components.getChatEndLiveMessage = function(resolve, reject) {
    var options = {
        name: 'message-chat-end-live',
        template: 'templates/message/end-live.html',
        props: ['message'],
        computed: {
            duration: function() {
                return this.message.content.duration;
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);