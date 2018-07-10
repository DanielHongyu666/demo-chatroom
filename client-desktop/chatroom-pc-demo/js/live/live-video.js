(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var chatroomList = RongIM.config.chatroomList;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;
var $ = dependencies.jQuery;
components.getLiveVideo = function(resolve, reject) {
    var options = {
        name: 'live-video',
        template: 'templates/live/live-video.html',
        data: function() {
            return {
   
            };
        },
        components: {
            like: components.getLiveLike,
            gift : components.getLiveGift
        },
        mounted: function() {
            watchReceiveBarrage(this);
        },
        destroyed: function() {
            dataModel.Barrage.unwatch(this.watchBarrage);
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

function watchReceiveBarrage(context) {
    var userApi = dataModel.User;
    context.watchBarrage = function(message) {
        var el = context.$el;
        var sendUser = userApi.getDetail(message.senderUserId);
        var content = utils.textMessageFormat(message.content.content);
        var params = {
            portrait: sendUser.portrait,
            name: sendUser.name,
            content: content,
            $parent: $(el)
        };
        sendBarrage(params);
    };
    dataModel.Barrage.watch(context.watchBarrage);
}

/**
 * 发送弹幕
 * @param  {object} params
 * params.portrait  头像
 * params.name  用户名
 * params.content  弹幕内容
 * params.$parent
 */
function sendBarrage(params) {
    var $parentEl = params.$parent;
    var html = getBarrageTemp();
    html = html.replace(/\{(.+?)\}/g, function(key) {
        key = key.replace(/{|}/g, '');
        return params[key];
    });
    var $el = $(utils.getDom(html));
    // 10 -130
    var top = Math.floor(Math.random() * 120) + 10;
    // 5 - 25
    var duration =  Math.floor(Math.random() * 20 ) + 5;
    $parentEl.append($el);
    $el.css('top', top + 'px');
    $el.css('animation', 'barrage ' + duration + 's 1');
    setTimeout(function() {
        $el.remove();
    }, duration * 1000);
}

function getBarrageTemp() {
    return `
        <div class="barrage-box">
            <i class="live-user-icon" style="background-image: url('{portrait}');"></i>
            <div class="live-user-detail">
                <p class="live-user-name">{name}:</p>
                <p class="barrage-text">{content}</p>
            </div>
        </div>
    `;
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);