(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var chatroomList = RongIM.config.chatroomList;
var dataModel = RongIM.dataModel;
var cache = utils.cache;

components.getLogin = function(resolve, reject) {
    var options = {
        name: 'login',
        template: 'templates/login/login.html',
        data: function() {
            return {
                chatroomList: chatroomList,
                isBusy: false
            }
        },
        mounted: function() {
            
        },
        methods: {
            getPortraitStyle: function(chat) {
                var url = 'url(' + chat.portrait + ')';
                return {
                    'background-image': url
                };
            },
            login: function(room, number) {
                var context = this;
                if (context.isBusy) {
                    return alert('登录失败');
                }
                var im = RongIM.instance;
                var chatRoomId = room.id;
                context.isBusy = true;
                dataModel.User.login(chatRoomId, function(err, user) {
                    context.isBusy = false;
                    im.auth = user;
                }, number);
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);