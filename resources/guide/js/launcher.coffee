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


class LauncherLaunch extends Page
    constructor:(@id)->
        super
        
        LAUNCHER = "com.deepin.dde.launcher"
        try
            @launcher_dbus = DCore.DBus.session(LAUNCHER)
        catch e
            console.log "launcher_dbus error :#{e}"
        
        @dock = new Dock()
        
        @message = _("Move the mouse to Left up corner , or you can click the launcher icon to launch \" Application Launcher\"")
        @show_message(@message)
        
        @corner_leftup = new Pointer("corner_leftup",@element)
        @corner_leftup.create_pointer(AREA_TYPE.corner,POS_TYPE.leftup)
        @corner_leftup.set_area_pos(0,0,"fixed",POS_TYPE.leftup)
        
        @circle = new Pointer("launcher_circle",@element)
        @circle.create_pointer(AREA_TYPE.circle,POS_TYPE.rightdown,=>
            @launcher_dbus?.Toggle()
            guide?.switch_page(@,"LauncherCollect")
        )
        @pos = @dock.get_launchericon_pos()
        @circle_x = @pos.x0 - @circle.pointer_width + ICON_MARGIN_H
        @circle_y = @pos.y0 - @circle.pointer_height - ICON_MARGIN_V_BOTTOM / 2
        @circle.set_area_pos(@circle_x,@circle_y,"fixed",POS_TYPE.leftup)



        
class LauncherCollect extends Page
    constructor:(@id)->
        super
        
        @rect = new Rect("collectApp",@element)
        @rect.create_rect(1096,316)#1096*316
        @rect.set_pos(135,80)
        
        @message = _("There are some collect applications in the first page of \"launcher\"")
        @show_message(@message)
        @msg_tips.style.marginTop = "150px"
        setTimeout(=>
            guide?.switch_page(@,"LauncherScroll")
        ,2000)

class LauncherAllApps extends Page
    constructor:(@id)->
        super

        @pointer = new Pointer("ClickToAllApps",@element)
        @pointer.create_pointer(AREA_TYPE.circle,POS_TYPE.leftup,=>
                DCore.Guide.disable_guide_region()
        )
        @pointer.set_area_pos(25,25)
        
        @message = _("There are some collect applications in the first page of \"launcher\"")
        @show_message(@message)

class LauncherScroll extends Page
    constructor:(@id)->
        super
        
        @rect = new Rect("collectApp",@element)
        @rect.create_rect(64,435)#1096*316
        @rect.set_pos(25,125)
        
        @pointer = new Pointer("classify",@element)
        @pointer.create_pointer(AREA_TYPE.circle,POS_TYPE.leftup)
        @pointer.set_area_pos(25,192)
        
        @message = _("Scroll the mouse to check all applications\n And you can click the left classification to locate")
        @show_message(@message)

        @scroll = create_element("div","srcoll",@element)
        @scroll.style.position = "absolute"
        @scroll.style.top = "37%"
        @scroll.style.right = "200px"
        
        @scroll_down = create_img("scroll_down","#{@img_src}/pointer_down.png",@scroll)
        @scroll_up = create_img("scroll_up","#{@img_src}/pointer_up.png",@scroll)
        
        width = height = 64
        @scroll.style.width = width
        @scroll.style.height = height * 2 + 50
        @scroll_down.style.width = @scroll_up.style.width = width
        @scroll_down.style.height = @scroll_up.style.height = height
        @scroll_up.style.position = "absolute"
        @scroll_up.style.left = 0
        @scroll_up.style.bottom = 0


class LauncherSearch extends Page
    constructor:(@id)->
        super
        
        @message = _("Input by keyboard to search the application what you want\nLet\'s try to input \"deepin\"")
        @tips = _("tips:Please input \"deepin\" directely")
        @show_message(@message)
        @show_tips(@tips)


class LauncherRightclick extends Page
    constructor:(@id)->
        super
        
        @message = _("在应用图标上单击鼠标右键可以调出右键菜单\n点击菜单项将实现其功能")
        @tips = _("tips:你也可以直接用鼠标左键拖拽图标到dock、收藏图标上或者垃圾箱上")
        @show_message(@message)
        @show_tips(@tips)


class LauncherMenu extends Page
    constructor:(@id)->
        super
        
        @message = _("使用鼠标右键发送2个图标到桌面")
        @show_message(@message)

        @menu = create_img("menu_#{@id}","#{@img_src}/menu.png",@element)
        set_pos(@menu,"41%","55%")


