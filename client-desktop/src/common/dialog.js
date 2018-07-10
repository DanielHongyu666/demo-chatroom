'use strict'
const {
    dialog
} = require('electron');

exports.showError = function (error) {
  var locale = global.locale;
  dialog.showErrorBox(locale.__('main.UncaughtException.Title'), [
    error.toString(),
    "\n",
    locale.__('main.UncaughtException.Content'),
    locale.__('main.UncaughtException.Website') + ": http://www.rongcloud.cn",
    locale.__('main.UncaughtException.Email') + ": support@rongcloud.cn"
  ].join("\n"))
}

exports.handleError = function (error, extra, isShowError) {
   console.log('err', error, extra);
}

exports.showMessageBox = function (params, callback) {
  dialog.showMessageBox({
    type: params.type,
    buttons: ['OK'],
    icon: iconPath,
    message: params.message,
    title: params.title,
    detail: params.detail
  }, callback)
}