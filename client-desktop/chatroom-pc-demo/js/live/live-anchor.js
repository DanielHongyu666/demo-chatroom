(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var getTotalGift = utils.getTotalGift;
var chatroomList = RongIM.config.chatroomList;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;
var im;
/*
    主播详情, 包含关注数, 礼物数, 获赞数
 */
components.getLiveAnchor = function(resolve, reject) {
    im = RongIM.instance;
    var options = {
        name: 'live-anchor',
        template: 'templates/live/live-anchor.html',
        data: function() {
            return {
                anchor: im.auth,
                followList: [],
                giftCount: 0,
                likeCount: 0
            }
        },
        mounted: function() {
            setFollowList(this);
            setTotalGift(this);
            watchReceiveGift(this);
            watchReceiveLike(this);
        },
        destroyed: function() {
            dataModel.Gift.unwatch(this.watchGift);
            dataModel.Gift.unwatch(this.watchLike);
        },
        methods: {

        }
    };
    utils.asyncComponent(options, resolve, reject);
};

function setFollowList(context) {
    dataModel.Follow.getFollowUsers(function(err, users) {
        context.followList = users;
    });
}

function watchReceiveGift(context) {
    context.watchGift = function() {
        setTotalGift(context);
    };
    dataModel.Gift.watch(context.watchGift);
}

function watchReceiveLike(context) {
    context.watchLike = function(message) {
        var counts = message.content.counts;
        context.likeCount += counts;
    };
    dataModel.Like.watch(context.watchLike);
}

function setTotalGift(context) {
    dataModel.Gift.get(function(err, gift) {
        context.giftCount = getTotalGift(gift);
    });
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);