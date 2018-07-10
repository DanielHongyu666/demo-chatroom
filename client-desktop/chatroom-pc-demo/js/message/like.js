(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;

components.getChatLikeMessage = function(resolve, reject) {
    var options = {
        name: 'message-chat-like',
        template: 'templates/message/like.html',
        props: ['message'],
        computed: {
            count: function() {
                var counts = this.message.content.counts;
                return counts;
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);