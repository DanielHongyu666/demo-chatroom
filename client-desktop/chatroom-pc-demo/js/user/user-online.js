(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
components.getUserOnline = function(resolve, reject) {
    var options = {
        name: 'user-online',
        template: 'templates/user/user-online.html',
        data: function() {
            return {
                onlineUsers: []
            }
        },
        mounted: function() {
            var context = this;
            dataModel.OnlineUser.getOnlineUsers(function(err, onlineUsers) {
                context.onlineUsers = onlineUsers;
                context.hidePanel();
            });
        },
        components: {
            blockPanel: components.getBlockPanel
        },
        methods: {
            showBlockPanel: function(index) {
                this.hidePanel();
                var user = this.onlineUsers[index];
                user.isShowBlockPanel = true;
                Vue.set(this.onlineUsers, index, user);
            },
            hidePanel: function() {
                hideOnlineUsers(this);
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

function hideOnlineUsers(context) {
    context.onlineUsers.forEach(function(user, index) {
        user.isShowBlockPanel = false;
        Vue.set(context.onlineUsers, index, user);
    });
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);