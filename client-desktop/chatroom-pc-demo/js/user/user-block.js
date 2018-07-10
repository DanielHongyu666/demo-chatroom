(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var chatroomList = RongIM.config.chatroomList;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;
var BlockType = utils.BlockType;
components.getUserBlock = function(resolve, reject) {
    var options = {
        name: 'user-block',
        template: 'templates/user/user-block.html',
        props: [ 'blockType' ],
        data: function() {
            return {
                blockUsers: []
            }
        },
        computed: {
            isBan: function() {
                return this.blockType === BlockType.Ban;
            }
        },
        watch: {
            blockType: function() {
                setUsers(this);
            }
        },
        mounted: function() {
            setUsers(this);
        },
        methods: {
            getReleaseTime: function(user) {
                var sentTime = user.message.sentTime;
                var blockTime = user.message.content.duration;
                var releaseTime = sentTime + blockTime;
                return utils.formatDateTime(releaseTime);
            },
            unBlock: function(user) {
                var chatroomId = this.$route.params.chatRoomId;
                var params = {
                    targetId: chatroomId,
                    id: user.id,
                };
                var unBlock = this.isBan ? dataModel.BanUser.unBan : dataModel.BlockUser.unBlock;
                unBlock(params, function(err) {
                    if (err) {
                        // TODO 报错提示
                    }
                });
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

function setUsers(context) {
    var getUsers = context.isBan ? dataModel.BanUser.getUsers : dataModel.BlockUser.getUsers;
    getUsers(function(err, blockUsers) {
        context.blockUsers = blockUsers;
    });
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);