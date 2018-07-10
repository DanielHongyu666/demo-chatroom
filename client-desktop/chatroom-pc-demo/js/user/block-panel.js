(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var chatroomList = RongIM.config.chatroomList;
var dataModel = RongIM.dataModel;
var BlockType = {
    block: 1,
    ban: 2
};

components.getBlockPanel = function(resolve, reject) {
    var options = {
        name: 'user-ban',
        template: 'templates/user/block-panel.html',
        props: ['hide', 'user'],
        data: function() {
            return {
                blockType: null,
                selectTime: 1
            }
        },
        computed: {
            blockTitle: function() {
                return this.blockType === BlockType.block ? '封禁' : '禁言';
            },
            blockTimeList: function() {
                return [1, 5, 10, 15, 30, 60];
            }
        },
        mounted: function() {
            watchPanelHidden(this);
        },
        methods: {
            selectBlock: function() {
                this.blockType = BlockType.block;
            },
            selectBan: function() {
                this.blockType = BlockType.ban;
            },
            block: function() {
                var context = this;
                var selectTime = this.selectTime;
                var isBan = context.blockType === BlockType.ban;
                var blockFuc = isBan ? dataModel.BanUser.ban : dataModel.BlockUser.block;
                var chatroomId = context.$route.params.chatRoomId;
                var params = {
                    targetId: chatroomId,
                    id: context.user.id,
                    duration: selectTime
                };
                blockFuc(params, function() {
                    context.hide();
                });
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

function watchPanelHidden(context) {
    var im = RongIM.instance;
    im.$on('imclick', function(event) {
        var $target = $(event.target);
        var wrap = '.block-panel, .user-online-desc';
        var inBody = $target.closest('body').length > 0;
        var inWrap = $target.closest(wrap).length < 1;
        var isOuter = inBody && inWrap;
        isOuter && context.hide();
    });
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);