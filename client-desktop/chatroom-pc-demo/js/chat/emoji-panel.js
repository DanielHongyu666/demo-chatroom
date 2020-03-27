(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;
var RongIMLib = dependencies.RongIMLib;
var RongIMEmoji = RongIMLib.RongIMEmoji;
components.getEmojiPanel = function(resolve, reject) {
    var options = {
        name: 'message-emoji-panel',
        template: 'templates/chat/emoji-panel.html',
        props: [ 'setEmoji', 'hide' ],
        data: function() {
            return {
                emojiList: []
            }
        },
        computed: {
            
        },
        mounted: function() {
            var list = RongIMEmoji.list;
            this.emojiList = list;
            watchPanelHidden(this);
        },
        methods: {
            getNodeHtml: function(node) {
                return node.outerHTML;
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

function watchPanelHidden(context) {
    var im = RongIM.instance;
    im.$on('imclick', function(event) {
        var $target = $(event.target);
        var wrap = '.emoji-panel, .input-send a';
        var inBody = $target.closest('body').length > 0;
        var inWrap = $target.closest(wrap).length < 1;
        var isOuter = inBody && inWrap;
        isOuter && context.hide();
    });
}

})(RongIM, {
    jQuery: jQuery,
    RongIMLib: RongIMLib
}, RongIM.components);