(function(RongIM) {
'use strict';

window.RongDesktop = {
    require: function() {
        return {};
    }
};

var lib = {
    getDataProvider: function() {
    },
    clearUnreadCountByTimestamp: function() {
    },
    isSupport: false
};

RongIM.lib = lib;

RongIM.system = {
    platform: 'web',
    getDeviceId: function() {
        return null;
    }
};

})(RongIM, window);