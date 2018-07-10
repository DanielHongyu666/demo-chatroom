(function(RongIM, RongDesktop) {
'use strict';
var IMLib = RongDesktop.require('IMLib');
var System = RongDesktop.require('System');
var lib = {
    getDataProvider: function() {
        return IMLib;
    },
    dbPath: System.dbPath,
    isSupport: true
};
RongIM.platform = System.getPlatform();

RongIM.lib = lib;

RongIM.system = {
    platform: System.getPlatform(),
    getDeviceId: System.getDeviceId
};

})(RongIM, RongDesktop);