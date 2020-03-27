(function (RongIM, dependencies, components) {
    'use strict';
    var utils = RongIM.utils;
    var chatroomImgList = RongIM.config.chatroomList;
    var dataModel = RongIM.dataModel;

    function checkChartName(name) {
        return new RegExp(/^[a-zA-Z0-9]{1,20}$/).test(name);
    }

    function initChatRoomList(context) {
        dataModel.getLiveRoomList({
            onSuccess: function (list) {
                context.chatroomList = list;
            },
            onError: function () {
                RongIM.utils.messagebox({
                    message: '获取直播房间列表失败'
                });
            }
        });
    }

    components.getLogin = function (resolve, reject) {
        var options = {
            name: 'login',
            template: 'templates/login/login.html',
            data: function () {
                return {
                    chatroomList: [],
                    isBusy: false,
                    chartName: '',
                    userName: '',
                    chartNameTip: '',
                    userNameTip: '',
                    chatroomImg: '',
                    random: 0,
                    text:'开始直播'
                }
            },
            mounted: function () {
                var context = this;
                context.random = utils.getRandomNumber(6);
                context.chatroomImg = "./img/cover/chatroom_0" + (context.random + 1) + ".png"
                initChatRoomList(context);
            },
            computed: {
                isAudience: function () {
                    return RongIM.instance.isAudience;
                }
            },
            methods: {
                getPortraitStyle: function (room) {
                    var url = room.portrait;
                    if (!url) {
                        var index = utils.getRandomNumber(chatroomImgList.length);
                        url = chatroomImgList[index];
                    }
                    url = 'url(' + url + ')';
                    return {
                        'background-image': url
                    };
                },
                start: function () {
                    var chartName = this.chartName;
                    if (!this.chartName || this.chartName.length > 20) {
                        this.chartNameTip = '名称不能为空。长度1-20个字符'
                        return;
                    }
                    if (!this.userName || this.userName.length > 10) {
                        this.chartNameTip = '';
                        this.userNameTip = '名称不能为空, 长度1-10个字符'
                        return;
                    }
                    this.chartNameTip = '';
                    this.userNameTip = '';
                    let chart = {
                        // id: this.chartName,
                        id: "web-" + utils.MD5(this.chartName) + "-" + new Date().getTime().toString(),
                        name: this.chartName,
                        random: this.random
                    }
                    this.login(chart, this.userName);
                },
                login: function (room, userName) {
                    var context = this;
                    this.text = '请等待...';
                    if (context.isBusy) {
                        return;
                    }
                    var im = RongIM.instance;
                    context.isBusy = true;
                    dataModel.User.login(room, function (err, user) {
                        context.isBusy = false;
                        // context.text = '开始直播';
                        user.random = room.random || room.coverIndex;
                        user.room = room;
                        im.auth = user;
                    }, userName);
                }
            }
        };
        utils.asyncComponent(options, resolve, reject);
    };

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);