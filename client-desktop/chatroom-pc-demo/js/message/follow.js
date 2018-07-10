(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;

components.getChatFollowMessage = function(resolve, reject) {
    var options = {
        name: 'message-chat-follow',
        template: 'templates/message/follow.html',
        props: ['message']
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);