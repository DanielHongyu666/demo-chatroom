(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var TabType = utils.BlockType;
var TabList = [
    { name: '在线用户', type: TabType.Online },
    { name: '禁言用户', type: TabType.Ban },
    { name: '封禁用户', type: TabType.Block }
];
var AudienceTabList = [
    { name: '在线用户', type: TabType.Online }
];

components.getUserList = function(resolve, reject) {
    var options = {
        name: 'userList',
        template: 'templates/user/user-list.html',
        data: function() {
            return {
                selectedType: TabType.Online
            }
        },
        computed: {
            isAudience: function () {
                return RongIM.instance.isAudience;
            },
            TabList: function() {
                return this.isAudience ? AudienceTabList : TabList;
            },
            selectedComponent: function() {
                return {
                    0: 'online',
                    1: 'block',
                    2: 'block'
                }[this.selectedType];
            }
        },
        mounted: function() {
            
        },
        components: {
            online: components.getUserOnline,
            block: components.getUserBlock
        },
        methods: {
            // 切换用户列表
            switchUserTab: function(type) {
                this.selectedType = type;
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);