(function(RongIM, dependencies) {
'use strict';
var $ = dependencies.jQuery;
var components = RongIM.components;

RongIM.routes = {
    linkActiveClass: 'rong-selected',
    maps: [
        {
           path: '/login',
           name: 'login',
           component: components.getLogin
        },
        {
            path: '/chatroom/:chatRoomId?',
            name: 'chatroom',
            component: components.getChatRoom
        },
        {
            path: '*',
            redirect: '/chatroom'
        }
    ]
};

})(RongIM, {
    jQuery: jQuery
})