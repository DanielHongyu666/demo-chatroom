const {
  remote
} = require('electron');
const path = require('path');
const config = require('../../config');
const Navi = require('./navi');
const rongSDKVersion = '2.9.3';

let imsdk = null;
try {
  let {
    modules: {
      rongimlib: {
        newname
      }
    }
  } = config;
  let platform = process.platform;
  let sdkPath = path.join(__dirname, platform, 'RongIMLib.node');
  imsdk = remote.require(sdkPath);
} catch (err) {
  console.error('require rongimlib error', err);
}

let ErrorCode = {
  NETWORK_AVAILABLE: 30004,
  // 请求超时
  IMEOUT: 30005,
  // 请求导航状态码非 200、401、403
  NAVI_RESP: 30007,
  // 导航数据解析后，其中不存在 Server
  NODE_NOT_FOUND: 30008,
  // Appkey、Token 不匹配
  APPID_TOKEN_UNMATCH: 31004
};

let Cache = {};

let getNavi = () => {
  let {options: {navi}} = Cache;
  return new Promise((resolve, reject) => {
    let {
      appkey,
      version,
      token,
      userId
    } = Cache.options;
    Navi.get({
      appkey,
      token,
      userId,
      version,
      url: navi
    }, (error, result) => {
      if (error) {
        return reject(error);
      }
      if(!result.server){
        return reject({
          code: ErrorCode.NODE_NOT_FOUND
        });
      }
      resolve(result);
    });
  });
};

let handlerError = (error) => {
  console.log(error);
  let connectWatcher = Cache.connectWatcher || function(){};
  let code = error.code;
  let isUnMatch = (code == 401 || code == 403);
  if (isUnMatch) {
    return connectWatcher(ErrorCode.APPID_TOKEN_UNMATCH);
  }

  let isOffLine = (code == 'ENOTFOUND');
  if (isOffLine) {
    return connectWatcher(ErrorCode.NETWORK_AVAILABLE);
  }

  let isInvalid = (code == ErrorCode.NODE_NOT_FOUND);
  if (isInvalid) {
    return connectWatcher(code);
  }

  let unkownCode = (code == 401 && code == 403);
  if (unkownCode) {
    return connectWatcher(ErrorCode.NAVI_RESP);
  }

};

class IMLib {
  static initWithAppkey(appkey, dbPath, options) {
    options = options || {};
    options.appkey = appkey;

    Cache.options = options;

    if (imsdk) {
      return imsdk.initWithAppkey(appkey, dbPath);
    }
  }
  static setConnectionStatusListener(watcher) {
    Cache.connectWatcher = watcher;
    if (imsdk) {
      return imsdk.setConnectionStatusListener((status) => {
        switch (status) {
          case 31006:
          case 32061:
            getNavi().then((navi) => {
              let options = Cache.options;
              imsdk.connectWithToken(options.token, navi.userId, navi.serverList, rongSDKVersion, !!navi.openMp, !!navi.openMp);
            }, (error) => {
              handlerError(error);
            });
            break;
          default:
            setTimeout(function() {
              watcher(status);
            });
            break;
        }
      });
    }
  }
  static setOnReceiveMessageListener(watcher) {
    if (imsdk) {
      return imsdk.setOnReceiveMessageListener(watcher);
    }
  }
  static connectWithToken(token, userId) {
    let options = Cache.options;
    if (imsdk) {
      options.token = token;
      options.userId = userId;
      getNavi().then((navi) => {
        imsdk.connectWithToken(token, navi.userId, navi.serverList, rongSDKVersion, !!navi.openMp, !!navi.openMp);
      }, (error) => {
        handlerError(error);
      });
    }
  }
  static reconnect(callback) {
    if (imsdk) {
      return imsdk.reconnect(callback);
    }
  }
  static disconnect(isDisconnect) {
    if (imsdk) {
      return imsdk.disconnect(isDisconnect);
    }
  }
  static sendReceiptResponse(conversationType, targetId, sendCallback) {
    if (imsdk) {
      return imsdk.sendReceiptResponse(conversationType, targetId, sendCallback);
    }
  }
  static recallMessage(objectName, content, push, success, error) {
    if (imsdk) {
      return imsdk.recallMessage(objectName, content, push, success, error);
    }
  }
  static sendTypingStatusMessage(conversationType, targetId, messageName, sendCallback) {
    if (imsdk) {
      return imsdk.sendTypingStatusMessage(conversationType, targetId, messageName, sendCallback);
    }
  }
  static sendTextMessage(conversationType, targetId, content, sendMessageCallback) {
    if (imsdk) {
      return imsdk.sendTextMessage(conversationType, targetId, content, sendMessageCallback);
    }
  }
  static getRemoteHistoryMessages(conversationType, targetId, timestamp, count, success, error) {
    if (imsdk) {
      return imsdk.getRemoteHistoryMessages(conversationType, targetId, timestamp, count, success, error);
    }
  }
  static hasRemoteUnreadMessages(token, callback) {
    if (imsdk) {
      return imsdk.hasRemoteUnreadMessages(token, callback);
    }
  }
  static getRemoteConversationList(callback, conversationTypes, count) {
    if (imsdk) {
      return imsdk.getRemoteConversationList(callback, conversationTypes, count);
    }
  }
  static removeConversation(conversationType, targetId, callback) {
    if (imsdk) {
      return imsdk.removeConversation(conversationType, targetId, callback);
    }
  }
  static addMemberToDiscussion(discussionId, userIdList, callback) {
    if (imsdk) {
      return imsdk.addMemberToDiscussion(discussionId, userIdList, callback);
    }
  }
  static createDiscussion(name, userIdList, callback) {
    if (imsdk) {
      return imsdk.createDiscussion(name, userIdList, callback);
    }
  }
  static getDiscussion(discussionId, callback) {
    if (imsdk) {
      return imsdk.getDiscussion(discussionId, callback);
    }
  }
  static quitDiscussion(discussionId, callback) {
    if (imsdk) {
      return imsdk.quitDiscussion(discussionId, callback);
    }
  }
  static removeMemberFromDiscussion(discussionId, userId, callback) {
    if (imsdk) {
      return imsdk.removeMemberFromDiscussion(discussionId, userId, callback);
    }
  }
  static setDiscussionInviteStatus(discussionId, status, callback) {
    if (imsdk) {
      return imsdk.setDiscussionInviteStatus(discussionId, status, callback);
    }
  }
  static setDiscussionName(discussionId, name, callback) {
    if (imsdk) {
      return imsdk.setDiscussionName(discussionId, name, callback);
    }
  }
  static joinGroup(groupId, groupName, callback) {
    if (imsdk) {
      return imsdk.joinGroup(groupId, groupName, callback);
    }
  }
  static quitGroup(groupId, callback) {
    if (imsdk) {
      return imsdk.quitGroup(groupId, callback);
    }
  }
  static syncGroup(groups, callback) {
    if (imsdk) {
      return imsdk.syncGroup(groups, callback);
    }
  }
  static joinChatRoom(chatroomId, messageCount, success, error) {
    if (imsdk) {
      return imsdk.joinChatRoom(chatroomId, messageCount, success, error);
    }
  }
  static getChatRoomInfo(chatRoomId, count, order, callback) {
    if (imsdk) {
      return imsdk.getChatRoomInfo(chatroomId, success, error);
    }
  }
  static quitChatRoom(chatroomId, success, error) {
    if (imsdk) {
      return imsdk.quitChatRoom(chatroomId, success, error);
    }
  }
  static addToBlacklist(userId, success, error) {
    if (imsdk) {
      return imsdk.addToBlacklist(userId, success, error);
    }
  }
  static getBlacklist(success, error) {
    if (imsdk) {
      return imsdk.getBlacklist(success, error);
    }
  }
  static getBlacklistStatus(userId, success, error) {
    if (imsdk) {
      return imsdk.getBlacklistStatus(userId, success, error);
    }
  }
  static removeFromBlacklist(userId, success, error) {
    if (imsdk) {
      return imsdk.removeFromBlacklist(userId, success, error);
    }
  }
  static getFileToken(fileType, callback) {
    if (imsdk) {
      return imsdk.getFileToken(fileType, callback);
    }
  }
  static getFileUrl(fileType, fileName, oriName, callback) {
    if (imsdk) {
      return imsdk.getFileUrl(fileType, fileName, oriName, callback);
    }
  }
  static sendMessage(conversationType, targetId, objectname, messageContent, pushText, appData, progress, success, error, mentiondMsg) {
    if (imsdk) {
      return imsdk.sendMessage(conversationType, targetId, objectname, messageContent, pushText, appData, progress, success, error, mentiondMsg);
    }
  }
  static registerMessageType(messageType, persistentFlag) {
    if (imsdk) {
      return imsdk.registerMessageType(messageType, persistentFlag);
    }
  }
  static addConversation(conversation, callback) {
    if (imsdk) {
      return imsdk.addConversation(conversation, callback);
    }
  }
  static updateConversation(conversation) {
    if (imsdk) {
      return imsdk.updateConversation(conversation);
    }
  }
  static removeConversation(conversationType, targetId) {
    if (imsdk) {
      return imsdk.removeConversation(conversationType, targetId);
    }
  }
  static insertMessage(conversationType, targetId, senderUserId, objectName, content, success, error, diection) {
    if (imsdk) {
      return imsdk.insertMessage(conversationType, targetId, senderUserId, objectName, content, success, error, diection);
    }
  }
  static deleteMessages(delMsgs) {
    if (imsdk) {
      return imsdk.deleteMessages(delMsgs);
    }
  }
  static getMessage(messageId) {
    if (imsdk) {
      return imsdk.getMessage(messageId);
    }
  }
  static updateMessage(message, callback) {
    if (imsdk) {
      return imsdk.updateMessage(message, callback);
    }
  }
  static clearMessages(conversationType, targetId) {
    if (imsdk) {
      return imsdk.clearMessages(conversationType, targetId);
    }
  }
  static updateMessages(conversationType, targetId, key, value, callback) {
    if (imsdk) {
      return imsdk.updateMessages(conversationType, targetId, key, value, callback);
    }
  }
  static getConversation(conversationType, targetId) {
    if (imsdk) {
      return imsdk.getConversation(conversationType, targetId);
    }
  }
  static getConversationList(converTypes) {
    if (imsdk) {
      return imsdk.getConversationList(converTypes);
    }
  }
  static clearConversations(conversationType, targetId) {
    if (imsdk) {
      return imsdk.clearConversations(conversationType, targetId);
    }
  }
  static getHistoryMessages(conversationType, targetId, timestamp, count, objectnam, direction) {
    if (imsdk) {
      return imsdk.getHistoryMessages(conversationType, targetId, timestamp, count, objectnam, direction);
    }
  }
  static getRemoteHistoryMessages(conversationType, targetId, timestamp, count) {
    if (imsdk) {
      return imsdk.getRemoteHistoryMessages(conversationType, targetId, timestamp, count);
    }
  }
  static getTotalUnreadCount(conversationTypes) {
    if (imsdk) {
      return imsdk.getTotalUnreadCount(conversationTypes);
    }
  }
  static getConversationUnreadCount(conversationTypes, callback) {
    if (imsdk) {
      return imsdk.getConversationUnreadCount(conversationTypes, callback);
    }
  }
  static getUnreadCount(conversationType, targetId) {
    if (imsdk) {
      return imsdk.getUnreadCount(conversationType, targetId);
    }
  }
  static clearUnreadCount(conversationType, targetId) {
    if (imsdk) {
      return imsdk.clearUnreadCount(conversationType, targetId);
    }
  }
  static clearUnreadCountByTimestamp(conversationType, targetId, timestamp) {
    if (imsdk) {
      return imsdk.clearUnreadCountByTimestamp(conversationType, targetId, timestamp);
    }
  }
  static setConversationToTop(conversationType, targetId, isTop) {
    if (imsdk) {
      return imsdk.setConversationToTop(conversationType, targetId, isTop);
    }
  }
  static setConversationHidden(conversationType, targetId, isHidden) {
    if (imsdk) {
      return imsdk.setConversationHidden(conversationType, targetId, isHidden);
    }
  }
  static setMessageExtra(messageId, value, callback) {
    if (imsdk) {
      return imsdk.setMessageExtra(messageId, value, callback);
    }
  }
  static setMessageReceivedStatus(messageId, receivedStatus) {
    if (imsdk) {
      return imsdk.setMessageReceivedStatus(messageId, receivedStatus);
    }
  }
  static setMessageSentStatus(messageId, sentStatus) {
    if (imsdk) {
      return imsdk.setMessageSentStatus(messageId, sentStatus);
    }
  }
  static getUploadToken(fileType, success, error) {
    if (imsdk) {
      return imsdk.getUploadToken(fileType, success, error);
    }
  }
  static getDownloadUrl(fileType, fileName, oriName, success, error) {
    if (imsdk) {
      return imsdk.getDownloadUrl(fileType, fileName, oriName, success, error);
    }
  }
  static getChatroomInfo(chatRoomId, count, order, success, error) {
    if (imsdk) {
      return imsdk.getChatroomInfo(chatRoomId, count, order, success, error);
    }
  }
  static searchConversationByContent(conversationTypes, keyword) {
    if (imsdk) {
      return imsdk.searchConversationByContent(conversationTypes, keyword);
    }
  }
  static getDeltaTime() {
    if (imsdk) {
      return imsdk.getDeltaTime();
    }
  }
  static searchMessageByContent(conversationType, targetId, keyword, timestamp, count, total, callback) {
    if (imsdk) {
      return imsdk.searchMessageByContent(conversationType, targetId, keyword, timestamp, count, total, callback);
    }
  }
  static getUserStatus(userId, success, error) {
    if (imsdk) {
      return imsdk.getUserStatus(userId, success, error);
    }
  }
  static setUserStatus(status, success, error) {
    if (imsdk) {
      return imsdk.setUserStatus(status, success, error);
    }
  }
  static subscribeUserStatus(userIds, success, error) {
    if (imsdk) {
      return imsdk.subscribeUserStatus(userIds, success, error);
    }
  }
  static setOnReceiveStatusListener(listener) {
    if (imsdk) {
      return imsdk.setOnReceiveStatusListener(listener);
    }
  }
  static setServerInfo(info) {
    if (imsdk && imsdk.setServerInfo) {
      return imsdk.setServerInfo(info);
    }
  }
  static getUnreadMentionedMessages(conversationType, targetId) {
    if (imsdk) {
      return imsdk.getUnreadMentionedMessages(conversationType, targetId);
    }
  }
  static updateMessageReceiptStatus(conversationType, targetId, timesamp) {
    if (imsdk) {
      return imsdk.updateMessageReceiptStatus(conversationType, targetId, timesamp);
    }
  }
  static setMessageContent(messageId, content, objectName) {
    if (imsdk) {
      return imsdk.setMessageContent(messageId, content, objectName);
    }
  }
  static getConversationNotificationStatus(conversationType, targetId, success, error) {
    if (imsdk) {
      return imsdk.getConversationNotificationStatus(conversationType, targetId, success, error);
    }
  }
  static setConversationNotificationStatus(conversationType, targetId, status, success, error) {
    if (imsdk) {
      return imsdk.setConversationNotificationStatus(conversationType, targetId, status, success, error);
    }
  }
  static getConnectionStatus() {
    if (imsdk) {
      return imsdk.getConnectionStatus();
    }
  }
  static setDeviceId(deviceId) {
    if (imsdk) {
      return imsdk.setDeviceId(deviceId);
    }
  }
  static setEnvironment(isPrivate) {
    if (imsdk) {
      return imsdk.setEnvironment(isPrivate);
    }
  }
  static getVoIPKey(engineType, channelName, extra, success, error) {
    if (imsdk) {
      return imsdk.getVoIPKey(engineType, channelName, extra, success, error);
    }
  }
  static clearRemoteHistoryMessages(conversationType, targetId, timestamp, success, error) {
    if (imsdk) {
      return imsdk.clearRemoteHistoryMessages(conversationType, targetId, timestamp, success, error);
    }
  }
  static getAccounts() {
    if (imsdk) {
      return imsdk.getAccounts();
    }
  }
  static clearData() {
    if (imsdk) {
      return imsdk.clearData();
    }
  }
}
module.exports = IMLib;