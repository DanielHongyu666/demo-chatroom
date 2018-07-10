(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;

components.getChatRoomUserQuit = function(resolve, reject) {
    var options = {
        name: 'message-room-user-quit',
        template: 'templates/message/room-quit.html',
        props: ['message']
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);