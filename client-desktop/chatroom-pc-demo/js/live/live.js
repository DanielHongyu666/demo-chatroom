(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;

/*
   直播详情, 包括主播详情, 视频, 直播操作 三个部分
 */
components.getLive = function(resolve, reject) {
    var options = {
        name: 'live',
        template: 'templates/live/live.html',
        data: function() {
            return {
                
            }
        },
        components: {
            anchor: components.getLiveAnchor,
            liveVideo: components.getLiveVideo,
            operate: components.getLiveOperate
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);