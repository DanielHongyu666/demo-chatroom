(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var chatroomList = RongIM.config.chatroomList;
var dataModel = RongIM.dataModel;

components.getGiftDetail = function(resolve, reject) {
    var options = {
        name: 'gift-detail',
        template: 'templates/chat/gift-detail.html',
        props: ['gift'],
        data: function() {
            return {
                giftList: []
            };
        },
        computed: {
            
        },
        mounted: function() {
            setGiftDetail(this);
            watchReceiveGift(this);
        },
        destroyed: function() {
            dataModel.Gift.unwatch(this.watchGift);
        },
        methods: {
            
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

function watchReceiveGift(context) {
    context.watchGift = function() {
        setGiftDetail(context);
    };
    dataModel.Gift.watch(context.watchGift);
}

function setGiftDetail(context) {
    var userId = context.gift.user.id;
    dataModel.Gift.get(function(err, gift) {
        if (err) {
            // TODO 报错提示
            return;
        }
        var giftList = [];
        var userGift = gift[userId];
        for (var giftId in userGift) {
            var giftName = dataModel.Gift.getName(giftId);
            giftList.push({
                name: giftName,
                number: userGift[giftId].number
            });
        }
        context.giftList = giftList;
    });
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);