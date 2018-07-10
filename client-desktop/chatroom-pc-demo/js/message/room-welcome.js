(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;

components.getChatRoomWelcome = function(resolve, reject) {
    var options = {
        name: 'message-room-welcome',
        template: 'templates/message/room-welcome.html',
        props: ['message']
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);