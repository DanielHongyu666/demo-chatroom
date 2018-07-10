(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Queue = utils.Queue;
var giftQue = new Queue();

components.getLiveGift = function(resolve, reject) {
    var options = {
        name: 'live-gift',
        template: 'templates/live/gift.html',
        data: function() {
            return {
                isShow: false,
                gift: {
                    icon: '',
                    name: '',
                    number: 0
                },
                user: {
                    name: '',
                    portrait: ''
                }
            }
        },
        components: {
            
        },
        methods: {
            
        },
        mounted: function() {
            watchReceiveBarrage(this);
        },
        destroyed: function() {
            dataModel.Gift.unwatch(this.watchRecieveGift);
        }
    };
    utils.asyncComponent(options, resolve, reject);
};


function watchReceiveBarrage(context) {
    var userApi = dataModel.Gift;
    context.watchRecieveGift = function(message) {
        giftQue.add(function(callback) {
            setGiftDetail(context, message);
            setGiftUser(context, message);
            context.isShow = true;
            setTimeout(function() {
                context.isShow = false;
                callback();
            // 展示 3s
            }, 3000)
        });
        giftQue.run();
    };
    dataModel.Gift.watch(context.watchRecieveGift);
}

function setGiftDetail(context, message) {
    var giftId = message.content.id;
    var giftName = dataModel.Gift.getName(giftId);
    context.gift = {
        icon: giftId + '.png',
        name: giftName,
        number: message.content.number
    };
}

function setGiftUser(context, message) {
    var userId = message.senderUserId;
    var user = dataModel.User.getDetail(userId);
    context.user = user;
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);