
(function(global, factory) {
    if (typeof exports === 'object' && typeof module !== 'undefined') {
        module.exports = factory();
    } else if (typeof define === 'function' && define.amd) {
        define(factory);
    } else {
        var messageTypes = factory();
        global.RongMessageTypes = global.RongMessageTypes || {};
        global.RongMessageTypes.chatroom = messageTypes;
    }
})(window, function(){
    
return {
 "ChatroomStart": {
  "name": "RC:Chatroom:Start",
  "priority": 4,
  "channel": "App Server",
  "version": "1.0.0",
  "proto": {
   "time": "1525415951135",
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomEnd": {
  "name": "RC:Chatroom:End ",
  "priority": 1,
  "channel": "App Server",
  "version": "1.0.0",
  "proto": {
   "duration": 3600,
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomSummary": {
  "name": "RC:Chatroom:Summary",
  "priority": 2,
  "channel": "App Server",
  "version": "1.0.0",
  "proto": {
   "online": 800,
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomFollow": {
  "name": "RC:Chatroom:Follow",
  "priority": 3,
  "channel": "App Client",
  "version": "1.0.0",
  "proto": {
   "id": "u2018",
   "rank": 1,
   "level": 3,
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomLike": {
  "name": "RC:Chatroom:Like",
  "priority": 1,
  "channel": "App Client",
  "version": "1.0.0",
  "proto": {
   "counts": 5,
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomGift": {
  "name": "RC:Chatroom:Gift",
  "priority": 5,
  "channel": "App Client",
  "version": "1.0.0",
  "proto": {
   "id": "G008",
   "number": 530,
   "total": 900,
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomBarrage": {
  "name": "RC:Chatroom:Barrage",
  "priority": 5,
  "channel": "App Client",
  "version": "1.0.0",
  "proto": {
   "type": "D201801",
   "content": "hellowrold",
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomWelcome": {
  "name": "RC:Chatroom:Welcome",
  "priority": 3,
  "channel": "App Server",
  "version": "1.0.0",
  "proto": {
   "id": "u2018",
   "counts": 10,
   "rank": 3,
   "level": 1,
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomAdminAdd": {
  "name": "RC:Chatroom:Admin:Add",
  "priority": 1,
  "channel": "App Server",
  "version": "1.0.0",
  "proto": {
   "id": "u2018",
   "counts": 10,
   "level": 1,
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomAdminRemove": {
  "name": "RC:Chatroom:Admin:Remove",
  "priority": 1,
  "channel": "App Server",
  "version": "1.0.0",
  "proto": {
   "id": "u2018",
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomUserBlock": {
  "name": "RC:Chatroom:User:Block",
  "priority": 1,
  "channel": "App Server",
  "version": "1.0.0",
  "proto": {
   "id": "u2018",
   "duration": 3600,
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomUserUnBlock": {
  "name": "RC:Chatroom:User:UnBlock",
  "priority": 1,
  "channel": "App Server",
  "version": "1.0.0",
  "proto": {
   "id": "u2018",
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomUserBan": {
  "name": "RC:Chatroom:User:Ban",
  "priority": 1,
  "channel": "App Server",
  "version": "1.0.0",
  "proto": {
   "id": "u2018",
   "duration": 3600,
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomUserUnBan": {
  "name": "RC:Chatroom:User:UnBan",
  "priority": 1,
  "channel": "App Server",
  "version": "1.0.0",
  "proto": {
   "id": "u2018",
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomUserQuit": {
  "name": "RC:Chatroom:User:Quit",
  "priority": 1,
  "channel": "App Client",
  "version": "1.0.0",
  "proto": {
   "id": "u2018",
   "extra": "附加信息",
   "user":""
  }
 },
 "ChatroomLiveCmd": {
    "name": "RC:Chatroom:LiveCmd",
    "priority": 1,
    "channel": "App Client",
    "version": "1.0.0",
    "proto": {
     "cmdType": 1,
     "roomId": "roomid",
     "extra":"附加信息",
     "user":""
    }
   },
   "ChatroomSyncUserInfo": {
    "name": "RC:Chatroom:SyncUserInfo",
    "priority": 1,
    "channel": "App Client",
    "version": "1.0.0",
    "proto": {
     "userInfos": [],
     "extra":"附加信息",
     "user":""
    }
   }
};
});
