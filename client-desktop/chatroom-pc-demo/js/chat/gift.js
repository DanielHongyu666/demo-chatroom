(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
components.getChatGift = function(resolve, reject) {
    var options = {
        name: 'chat-gift',
        template: 'templates/chat/gift.html',
        data: function() {
            return {
                giftList: []
            };
        },
        computed: {
            
        },
        components: {
            giftDetail: components.getGiftDetail
        },
        mounted: function() {
            setGiftList(this);
            watchReceiveGift(this);
            watchPanelHidden(this);
        },
        destroyed: function() {
            dataModel.Gift.unwatch(this.watchGift);
        },
        methods: {
            showGiftPanel: function(gift) {
                this.hidePanel();
                gift.isShowPanel = true;
            },
            hidePanel: function() {
                this.giftList.forEach(function(gift) {
                    gift.isShowPanel = false;
                });
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

function watchReceiveGift(context) {
    context.watchGift = function() {
        setGiftList(context);
    };
    dataModel.Gift.watch(context.watchGift);
}

function setGiftList(context) {
    dataModel.Gift.get(function(err, gift) {
        if (err) {
            // TODO 
            return;
        }
        var list = [];
        for (var userId in gift) {
            var userGift = gift[userId];
            list.push({
                user: userGift.user,
                number: getUserGiftTotal(userGift),
                isShowPanel: false
            });
        }
        context.giftList = list.sort(function(one, another) {
            var oneNumber = parseInt(one.number);
            var anotherNumber = parseInt(another.number);
            return anotherNumber - oneNumber;
        });
    });
}


function getUserGiftTotal(userGift) {
    var total = 0;
    for (var giftId in userGift) {
        if('user'!=giftId){
            var gift = userGift[giftId];
            total += gift.number;
        }
    }
    return total;
}

function watchPanelHidden(context) {
    var im = RongIM.instance;
    im.$on('imclick', function(event) {
        var $target = $(event.target);
        var wrap = '.gift-panel, .gift-count';
        var inBody = $target.closest('body').length > 0;
        var inWrap = $target.closest(wrap).length < 1;
        var isOuter = inBody && inWrap;
        isOuter && context.hidePanel();
    });
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);