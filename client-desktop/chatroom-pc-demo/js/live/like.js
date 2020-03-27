(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;
var LikeShowDuration = 5000;
var LikeShowInterval = 400;
components.getLiveLike = function(resolve, reject) {
    var options = {
        name: 'live-like',
        template: 'templates/live/like.html',
        data: function() {
            return {
                likeList: Cache.likeList
            }
        },
        mounted: function() {
            watchReceiveLike(this);
        },
        destroyed: function() {
            dataModel.Like.unwatch(this.watchLike);
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

function watchReceiveLike(context) {
    var userApi = dataModel.User;
    var el = context.$el;
    context.watchLike = function(message) {
        var count = message.content.counts;
        var completedCount = 0;
        var interVal = setInterval(function() {
            completedCount++;
            showLike(el);
            completedCount === count && clearInterval(interVal);
        }, LikeShowInterval);
    };
    dataModel.Like.watch(context.watchLike);
}

function showLike(parentEl) {
    var $parent = $(parentEl);
    var html = getLikeTemp();
    var css = getLikeCssTemp();
    var $el = $(utils.getDom(html));
    var animationName = 'livemove-' + (+new Date());
    var rotate = Math.floor(Math.random() * 60) + 14;
    var cssParams = {
        name: animationName,
        left: Math.floor(Math.random() * 100),
        rotate: rotate
    };
    css = css.replace(/\{(.+?)\}/g, function(key) {
        key = key.replace(/{|}/g, '');
        return cssParams[key];
    });
    var head = utils.addStyle(css);
    $parent.append($el);
    var backColor = getRandomColor();
    $el.css('animation', `${animationName} 5s 1`);
    $el.css('transform', `rotate(${rotate}deg)`);
    $el.children().css('border-color', backColor);
    setTimeout(function() {
        $el.remove();
        head.remove();
    }, LikeShowDuration);
}

function getRandomColor() {
    var r = Math.floor(Math.random() * 256);
    var g = Math.floor(Math.random() * 256);
    var b = Math.floor(Math.random() * 256);
    return 'rgb(' + r + ',' + g + ',' + b  +  ')';
}

function getLikeTemp() {
    return `
        <div class="video-like">
            <div class="like-heart-square"></div>
            <div class="like-heart-round"></div>
            <div class="like-heart-round-second"></div>
        </div>
    `;
}

function getLikeCssTemp() {
    return `
        @keyframes {name}
        {
            0% {
                bottom: 30px;
                left: 40%;
            }
            100% {
                bottom: 100%;
                left: {left}%;
                opacity: 0;
                transform: scale(0.8, 0.8) rotate({rotate}deg);
            }
        }
    `;
}

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);