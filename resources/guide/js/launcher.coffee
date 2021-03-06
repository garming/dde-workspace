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
        enableZoneDetect(true)
        DCore.Guide.cursor_show()
        @dockReal = new Dock()
        @dockReal.hide()
        @dockMode = new DockMode("dockMode_#{_dm}",_dm,@element)

        @launcher = new Launcher()
        @launcher.hide()
        @message = _("\"Application Launcher\" can be started by sliding the mouse to the upper left corner or clicking on the launcher.")
        @show_message(@message)

        @corner_leftup = new Pointer("corner_leftup",@element)
        @corner_leftup.create_pointer(AREA_TYPE.corner,POS_TYPE.leftup,=>
            @tid_show_signal = setTimeout(@show_signal_cb,3000)
        ,"mouseenter")
        @corner_leftup.set_area_pos(0,0,"fixed",POS_TYPE.leftup)
        @corner_leftup.show_animation()
        @circle = new Pointer("launcher_circle",@element)
        circle_type = POS_TYPE.rightdown
        if _dm == DisplayMode.Fashion
            circle_type = POS_TYPE.rightdown
        else circle_type = POS_TYPE.leftdown
        @circle.create_pointer(AREA_TYPE.circle,circle_type,=>
            @launcher.show()
            @tid_show_signal = setTimeout(@show_signal_cb,3000)
        )
        setTimeout(=>
            @pos = @dockMode.get_icon_pos(@dockMode.get_launcher_index())
            switch _dm
                when DisplayMode.Fashion
                    @circle_x = @pos.x - @circle.pointer_width - 9
                    @circle_y = @pos.y - @circle.pointer_height - 8
                when DisplayMode.Efficient
                    @circle_x = @pos.x - @circle.pointer_width + 60
                    @circle_y = @pos.y - @circle.pointer_height - 8
                when DisplayMode.Classic
                    @circle_x = @pos.x - @circle.pointer_width + 60
                    @circle_y = @pos.y - @circle.pointer_height - 8
            @circle.set_area_pos(@circle_x,@circle_y,"fixed",POS_TYPE.leftup)
            @circle.show_animation()
        ,200)

        @launcher.show_signal(@show_signal_cb)

    show_signal_cb:=>
        clearTimeout(@tid_show_signal)
        enableZoneDetect(false)
        @element.style.display = "none"
        setTimeout(=>
            @launcher.show_signal_disconnect()
            @launcher?.show()
            @dockMode.destroy()
            @dockReal.show()
            guide?.switch_page(@,"LauncherSearch")
        ,t_min_switch_page)


class LauncherSearch extends Page
    constructor:(@id)->
        super
        @message = _("Please directly hit \"deepin\" in keyboard")
        @show_message(@message)

        new Launcher()?.show()
        @fcitx = new Fcitx()
        @fcitx?.setCurrentIM("fcitx-keyboard-us")
        setTimeout(=>
            simulate_input(@,"LauncherIconDrag")
        ,20)

class LauncherIconDrag extends Page
    constructor:(@id)->
        super
        @message = _("You can directly drag the application icon to Dock or trash")
        @show_message(@message)
        setTimeout(=>
            guide?.switch_page(@,"LauncherMenu")
        ,t_mid_switch_page)

class LauncherMenu extends Page
    APP_NAME_1 = "deepin-movie"
    APP_NAME_2 = "deepin-music-player"
    constructor:(@id)->
        super
        @launcher = new Launcher()
        @message = " "
        @tips = _("tips: Click the right mouse button on the application icon to call up the context menu")
        @show_message(@message)
        @show_tips(@tips)
        @signal() if !DEBUG
        src1 = "/usr/share/applications/#{APP_NAME_1}.desktop"
        DCore.Guide.copy_file_to_desktop(src1)
        src2 = "/usr/share/applications/#{APP_NAME_2}.desktop"
        DCore.Guide.copy_file_to_desktop(src2)

        @src_app_create_menu()

    src_app_create_menu: ->
        app_list = []
        launcher_daemon = new LauncherDaemon()
        app_list = launcher_daemon?.search("deepin")
        app1_index = i for app,i in app_list when app is APP_NAME_1
        if app1_index == null or app1_index == undefined then app1_index = 1
        app1_pos = launcher_daemon.app_x_y(app1_index)
        app1_offsetX = EACH_APP_WIDTH * 0.75
        app1_offsetY = EACH_APP_HEIGHT * 0.5
        @menu_create(app1_pos.x + app1_offsetX,app1_pos.y + app1_offsetY)

    menu_create: (x,y,cb) ->
        @menu =[
            {type:MENU.selected,text:_("_Open")},
            {type:MENU.cutline,text:""},
            {type:MENU.option,text:_("Remove from _favorites")},
            {type:MENU.option,text:_("Send to d_esktop")},
            {type:MENU.option,text:_("Send to do_ck")},
            {type:MENU.cutline,text:""},
            {type:MENU.option,text:_("_Add to autostart")},
            {type:MENU.option,text:_("_Uninstall")}
        ]
        @contextmenu = new ContextMenu("launcher_contextmenu",@element)
        @contextmenu.menu_create(@menu)
        @contextmenu.set_pos(x,y)
        DCore.Guide.cursor_hide()
        @contextmenu.selected_auto(0,@menu.length,1000,@switch_page)

    signal: ->
        @launcher?.hide_signal(=>
            @launcher?.show()
        )

    switch_page: =>
        setTimeout(=>
            @launcher?.hide_signal_disconnect() if !DEBUG
            @launcher?.hide()
            #DCore.Guide.spawn_command_sync("/usr/lib/deepin-daemon/desktop-toggle",true)
            DCore.Guide.cursor_show()
            guide?.switch_page(@,"DesktopRichDir")
        ,t_mid_switch_page)
