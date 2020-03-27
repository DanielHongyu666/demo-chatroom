(function (RongIM, dependencies, components) {
'use strict';
var utils = RongIM.utils;
var dataModel = RongIM.dataModel;
var Cache = dataModel.Cache;
/*
   直播详情, 包括主播详情, 视频, 直播操作 三个部分
 */
components.getLive = function(resolve, reject) {
    var options = {
        name: 'live',
        template: 'templates/live/live.html',
        data: function() {
            return {
                customType:'SUSPENSION',
                showSetting:false,
                layoutMode:{
                    SUSPENSION: 2, // 悬浮
                    ADAPTATION: 3, // 自适应布局
                    CUSTOMIZE: 1 // 自定义布局
                },
                isRenderCrop:false,
                switchText:'开|关',
                screenX: 0,
                height: 80,
                width: 107,
                showCustomizeInfo:false,
                messageBox:false,
                messageBoxTitle:'',
                curCustomType:'SUSPENSION',
                curIsRenderCrop:false,
            }
        },
        mounted: function() {
            RongIM.instance.$on('setConfig',()=>{
                this.saveConfig()
            })
        },
        components: {
            anchor: components.getLiveAnchor,
            liveVideo: components.getLiveVideo,
            operate: components.getLiveOperate
        },
        computed: {
			direction () {
				if (this.switchText) {
					return this.switchText.split('|')
				} else {
					return []
				}
            }
        },
        watch: {
            height: function (newVal) {
                if (newVal>80) {
                    this.height = 80;
                }
                this.width = Math.round(this.height/0.75)
            },
            customType: function(){
                if(this.customType == this.curCustomType){
                    this.isRenderCrop = this.curIsRenderCrop;
                }else{
                    this.isRenderCrop =false;
                }
            }
        },
        methods:{
            saveConfig:function(isClick){
                let content = this;
                let options = {
                    layoutMode:this.layoutMode[this.customType],
                    hostUserId:Cache.auth.id,
                    video: { // 己方发布 video 的配置项, 非必填
                        width: 640, // 非必填, 不填则按传入视频大小计算
                        height: 480,  // 非必填, 不填则按传入视频大小计算
                        fps: 15, // 非必填, 不填则按传入视频大小计算
                        renderMode: this.isRenderCrop ? 1 : 2
                   },
                   audio: { // 己方发布 audio 的配置项, 非必填
                        bitrate: 30 // 非必填, 不填则按传入视频大小计算
                   }
                }
                if(this.customType == 'CUSTOMIZE'){
                    options.customLayout = {};
                    options.customLayout.video = this.fomatInputvideo(); 
                }
                dataModel.Stream.setConfig(options).then(function (res) {
                    if(!isClick){
                        return;//增加，减少连麦人员修改配置暂不给提示成功后直接返回
                    }
                    if(res.resultCode == 10000){
                        content.messageBoxTitle = '修改成功';
                        if(content.customType == 'CUSTOMIZE'){
                            content.showCustomizeInfo = true;
                        }
                        content.showSetting = false;
                        content.curCustomType = content.customType;
                        content.curIsRenderCrop = content.isRenderCrop;
                    }else{
                        content.messageBoxTitle = '修改失败';
                    }
                    content.messageBox = true;
                    setTimeout(()=>{
                        content.messageBox = false;
                    },1500);
                })
            },
            changeShowSetting:function(flag){
                this.showSetting = flag;
                if(!flag){
                    this.customType = this.curCustomType;
                }
            },
            toggle() {
                this.isRenderCrop = !this.isRenderCrop;
            },
            fomatInputvideo:function(){
                let video = []
                //主播自己
                video.push({
                    user_id: Cache.auth.id,
                    x: 0,
                    y: 0,
                    width: 640,
                    height: 480
               });
               let num = 0;
               //连麦者
               for(let i=0;i < Cache.upgradeUsers.length; i++){
                   
                   if(Cache.upgradeUsers[i].id != Cache.auth.id){
                        let user ={
                            user_id: Cache.upgradeUsers[i].id,
                            x: parseInt(this.screenX),
                            y: parseInt(this.height)*(num),
                            width: parseInt(this.width),
                            height: parseInt(this.height)
                        }
                        video.push(user);
                        num ++;
                   }
                }
                return video
            }
        }
    };
    utils.asyncComponent(options, resolve, reject);
};

})(RongIM, {
    jQuery: jQuery
}, RongIM.components);