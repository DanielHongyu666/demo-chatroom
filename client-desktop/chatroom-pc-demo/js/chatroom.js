(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var cache = utils.cache;
var im;
components.getChatRoom = function(resolve, reject) {
    var options = {
        name: 'chatroom',
        template: 'templates/chatroom.html',
        data: function() {
            return {
                platform: RongIM.system.platform
            }
        },
        components: {
            userList: components.getUserList,
            chatList: components.getChatList,
            live: components.getLive
        },
        mounted: function() {

        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);