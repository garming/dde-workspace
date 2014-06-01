#Copyright (c) 2011 ~ 2014 Deepin, Inc.
#              2011 ~ 2014 bluth
#
#encoding: utf-8
#Author:      bluth <yuanchenglu@linuxdeepin.com>
#Maintainer:  bluth <yuanchenglu@linuxdeepin.com>
#
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, see <http://www.gnu.org/licenses/>.

class End extends Page
    constructor:(@id)->
        super
        
        @message = _("感谢您的耐心学习！您获得了新手礼包")
        @tips = _("tips：请在深度账号内领取")
        @show_message(@message)
        @show_tips(@tips)
        @msg_tips.style.top = "-10%"

        @choose_div = create_element("div","choose_div",@element)
        @getReward = new ButtonNext("GetReward",_("Get"),@choose_div)
        @getReward.create_button(=>
            #TODO: open the deepin accounts web url
            echo "open the deepin accounts web url"
        )
