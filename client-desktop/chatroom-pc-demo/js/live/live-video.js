(function (RongIM, dependencies, components) {
    'use strict';
    var utils = RongIM.utils;
    var dataModel = RongIM.dataModel;
    var Cache = dataModel.Cache;
    var $ = dependencies.jQuery;

    function getBarrageTemp() {
        return `
        <div class="barrage-box">
            <i class="live-user-icon" style="background-image: url('./img/avatar/avatar_{portrait}.png');"></i>
            <div class="live-user-detail">
                <p class="live-user-name">{name}:</p>
                <p class="barrage-text">{content}</p>
            </div>
        </div>
    `;
    }
    function createVideo(stream) {
        var video = document.createElement('video');
        video.srcObject = stream.mediaStream;
        video.autoplay = true;
        video.id = stream.id;
        video.name = '自己';
        video.className = 'rong-video';
        return video;
    };

    function appendVideoWithStream(stream, isSelf) {
        let video = createVideo(stream);
        if (isSelf) {
            video.muted = true;
        }
        document.querySelector('.live-content').appendChild(video);
    }

    components.getLiveVideo = function (resolve, reject) {
        var options = {
            name: 'live-video',
            template: 'templates/live/live-video.html',
            data: function () {
                return {

                };
            },
            components: {
                like: components.getLiveLike,
                gift: components.getLiveGift
            },
            mounted: function () {
                var im = RongIM.instance;
                watchReceiveBarrage(this);

                // 示例中以添加 video 节点流为例，可添加其他 MediaStream 对象，如: 屏幕共享、多摄像头等
                // let videoNode = document.querySelector('#mainVideo');
                // let mediaStream = videoNode.captureStream();
                // 获取摄像头

                if (im.isAudience) {
                    var room = im.auth.room;
                    // var liveUrl = room.mcuUrl.replace(/\+/g, ' ');
                    dataModel.Stream.subscribe({
                        liveUrl: room.mcuUrl
                    }).then(appendVideoWithStream).catch(function (error) {
                        utils.messagebox({
                            message: '观众订阅失败 ' + utils.stringify(error)
                        });
                    });
                } else {
                    dataModel.Stream.getMediaStream(function (stream) {
                        var isSelf = true;
                        appendVideoWithStream(stream, isSelf);
                        RongIM.instance.$emit('setConfig');
                    }).catch(function () {
                        utils.messagebox({
                            message: '获取摄像头或麦克风失败'
                        });
                    });
                }
            },
            destroyed: function () {
                dataModel.Barrage.unwatch(this.watchBarrage);
            }
        };
        utils.asyncComponent(options, resolve, reject);
    };

    function watchReceiveBarrage(context) {
        var userApi = dataModel.User;
        context.watchBarrage = function (message) {
            var el = context.$el;
            var sendUser = userApi.getDetail(message.senderUserId);
            var content = utils.textMessageFormat(message.content.content);
            var params = {
                portrait: message.content.user.portrait,
                name: message.content.user.name,
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
        html = html.replace(/\{(.+?)\}/g, function (key) {
            key = key.replace(/{|}/g, '');
            if ('portrait' == key) {
                params[key] = parseInt(params[key]) + 1;
            }
            return params[key];
        });
        var $el = $(utils.getDom(html));
        // 10 -130
        var top = Math.floor(Math.random() * 120) + 10;
        // 5 - 25
        var duration = Math.floor(Math.random() * 20) + 5;
        $parentEl.append($el);
        $el.css('top', top + 'px');
        $el.css('animation', 'barrage ' + duration + 's 1');
        setTimeout(function () {
            $el.remove();
        }, duration * 1000);
    }
})(RongIM, {
    jQuery: jQuery
}, RongIM.components);