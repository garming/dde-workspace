#Copyright (c) 2011 ~ 2012 Deepin, Inc.
#              2011 ~ 2012 yilang
#
#Author:      bluth <yuanchenglu@linuxdeepin.com>
#             LongWei <yilang2007lw@gmail.com>
#                     <snyh@snyh.org>
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

class MenuChoose extends Widget
    choose_num = -1
    select_state_confirm = false
    frame_click = true
    
    
    #var for animation
    t_userinfo_show_hide = 600
    t_userinfo_show_delay = 500

    t_max = 200
    t_min = 100
    t_delay = 30
    
    XMove = "-5em"
    XBack = "0"
    XStartShow = "80em"
    XEndHide = "80em"
    
    init_width = 80 * 0.8
    final_width = 80
    
    constructor: (@id)->
        super
        @current = @id
        
        @option = []
        @option_text = []
        @img_url_normal = []
        @img_url_hover = []
        @img_url_click = []

        @opt = []
        @opt_img = []
        @opt_text = []
        @animation_end = true
        
        document.body.style.fontSize = "62.5%"
        document.body.appendChild(@element)
        @element.style.display = "none"
    
 
    show:->
        @animation_end = false
        echo "show"
        animation_opt_text_show = (i)=>
            if i != @opt.length - 1 then return
            #echo "opt_text[#{i}] show"
            for tmp in @opt_text
                jQuery(tmp).animate(
                    {opacity:'1.0';},
                    t_min,
                    "linear",=>
                        @animation_end = true
                )


        animation_opt_move_show = (i,t_delay)=>
            #echo "animation_opt_move_show(#{i})"
            text_el = @opt_text[i]
            img_el = @opt_img[i]
            opt_el = @opt[i]
            
            #init el css and then can animate
            text_el.style.opacity = "0.0"
            
            img_el.style.width = "#{init_width / 10}em"
            img_el.style.height = "#{init_width / 10}em"
            
            opt_el.style.opacity = "0.0"
            opt_el.style.left = XStartShow
            
            animation_scale(img_el,final_width / init_width,t_max)
            jQuery(opt_el).delay(t_delay).animate(
                {opacity: 1.0;left:XMove},
                t_max,
                'linear',=>
                    jQuery(opt_el).animate(
                        {left:XBack;},
                        t_min,
                        'linear',=>
                        animation_opt_text_show(i)
                    )
            )

        jQuery('.div_users').animate(
            {opacity:'0.0';},
            t_userinfo_show_hide,
            'linear',=>
                $("#div_users").style.display = "none"
                if is_greeter
                    $(".prevuserinfo").style.display = "none"
                    $(".nextuserinfo").style.display = "none"
                
                @element.style.display = "-webkit-box"
                for tmp,i in @opt
                    animation_opt_move_show(i,i * t_delay)
        )


   
    hide:->
        echo "hide"
        @animation_end = false
        
        animation_user_show = (i)=>
            if i != 0 then return
            echo "animation_user_show(#{i})"
            $("#div_users").style.display = "-webkit-box"
            jQuery('.div_users').delay(t_userinfo_show_delay).animate(
                {opacity:'1.0';},
                t_userinfo_show_hide,
                "linear",=>
                    @element.style.display = "none"
                    @animation_end = true
            )

        animation_opt_move_hide = (i,t_delay)=>
            #echo "animation_opt_move_hide(#{i})"
            text_el = @opt_text[i]
            img_el = @opt_img[i]
            opt_el = @opt[i]

            jQuery(text_el).animate(
                {opacity:'0.0';},
                t_min,
                'linear',=>
                    jQuery(opt_el).animate(
                        {opacity:'0.5';left:XMove;},
                        t_min,
                        'linear',=>
                            #echo "opt_el[#{i}] Move From #{opt_el.style.left} To #{XEndHide}"
                            time = (t_min + t_delay) / 2
                            animation_scale(img_el,1.0,time)
                            jQuery(opt_el).animate(
                                {opacity:'0.0';left:XEndHide;},
                                time,
                                'linear',=>
                                animation_user_show(i)
                            )
                    )
            )


        j = 0
        for i in [@opt.length - 1..0]
            #delete select_state and then start animate
            @opt[i].style.backgroundColor = "rgba(255,255,255,0.0)"
            @opt[i].style.border = "1px solid rgba(255,255,255,0.0)"
            @opt[i].style.borderRadius = "0px"
            j++
            animation_opt_move_hide(i,j * t_delay)


    insert: (id, title, img_normal,img_hover,img_click)->
        @option.push(id)
        @option_text.push(title)
        @img_url_normal.push(img_normal)
        @img_url_hover.push(img_hover)
        @img_url_click.push(img_click)
    
    body_click_to_hide:->
        document.body.addEventListener("click",(e)=>
            e.stopPropagation()
            if !frame_click and @element.style.display isnt "none"
                echo "body_click_to_hide"
                if !@animation_end then return
                @hide()
                $(".password").focus()
            else
                frame_click = false
                @confirm_shutdown_hide()
        )
 

    frame_build:(id,title,img)->
        @frame = create_element("div", "frame", @element)
        @button = create_element("div","button",@frame)
       
        @frame.addEventListener("click",(e)->
            e.stopPropagation()
            frame_click = true
        )
        @body_click_to_hide()

        for tmp ,i in @option
            @opt[i] = create_element("div","opt",@button)
            @opt[i].style.backgroundColor = "rgba(255,255,255,0.0)"
            @opt[i].style.border = "1px solid rgba(255,255,255,0.0)"
            @opt[i].value = i
            
            @opt_img[i] = create_img("opt_img",@img_url_normal[i],@opt[i])
            @opt_text[i] = create_element("div","opt_text",@opt[i])
            @opt_text[i].textContent = @option_text[i]
            
            that = @
            #hover
            @opt[i].addEventListener("mouseover",->
                i = this.value
                choose_num = i
                that.opt_img[i].src = that.img_url_hover[i]
                that.hover_state(i)
            )
            
            #normal
            @opt[i].addEventListener("mouseout",->
                i = this.value
                that.opt_img[i].src = that.img_url_normal[i]
            )

            #click
            @opt[i].addEventListener("mousedown",->
                i = this.value
                that.opt_img[i].src = that.img_url_click[i]
            )
            @opt[i].addEventListener("click",(e)->
                e.stopPropagation()
                i = this.value
                frame_click = true
                that.opt_img[i].src = that.img_url_click[i]
                that.current = that.option[i]
                that.fade(i)
            )


    set_callback: (@cb)->

       
    confirm_shutdown_show:(powervalue)=>
        power = {"lock":true,"value":powervalue}
        localStorage.setObject("shutdown_from_lock",power)

        value = _("Input password to #{powervalue}")
        localStorage.setItem("password_value_shutdown",value)
        @password = $(".password")
        @loginbutton = $(".loginbutton")

        @password.style.color = "#ff8a00"
        @password.style.fontSize = "1.5em"
        @password.type = "text"
        @password.value = value
        @loginbutton.src = "images/userinfo/#{powervalue}_normal.png"
        @loginbutton.disable = true
        

    confirm_shutdown_hide:=>
        if not (power = localStorage.getObject("shutdown_from_lock"))? then return
        if !power.lock then return
        power.lock = false
        localStorage.setObject("shutdown_from_lock",power)

        @password = $(".password")
        @loginbutton = $(".loginbutton")
        @password.style.color = "rgba(255,255,255,0.5)"
        @password.style.fontSize = "2.0em"
        @password.type = "password"
        @password.focus()
        @loginbutton.disable = false
        @password.value = null
        
        jQuery(@loginbutton).animate(
            {opacity:'0.0';},
            t_userinfo_show_hide,
            "linear",=>
                @loginbutton.src = "images/userinfo/lock_normal.png"
                jQuery(@loginbutton).animate(
                    {opacity:'1.0';},
                    t_userinfo_show_hide
                )
        )

    fade:(i)->
        echo "--------------fade:#{@option[i]}---------------"
        @hide()
        if is_greeter
            echo "is_greeter"
            @cb(@option[i], @option_text[i])
        else
            echo "is_lock"
            if @id is "power_menuchoose" and @option[i] isnt "suspend"
                @confirm_shutdown_show(@option[i])
            else
                @cb(@option[i], @option_text[i])

    
    hover_state:(i)->
        choose_num = i
        if select_state_confirm then @select_state(i)
        for tmp,j in @opt_img
            if j == i then tmp.src = @img_url_hover[i]
            else tmp.src = @img_url_normal[j]
   
    select_state:(i)->
        select_state_confirm = true
        choose_num = i
        for tmp,j in @opt
            if j == i
                tmp.style.backgroundColor = "rgba(255,255,255,0.1)"
                tmp.style.border = "1px solid rgba(255,255,255,0.15)"
                tmp.style.borderRadius = "4px"
            else
                tmp.style.backgroundColor = "rgba(255,255,255,0.0)"
                tmp.style.border = "1px solid rgba(255,255,255,0.0)"
                tmp.style.borderRadius = "0px"

    
    keydown:(e)->
        switch e.which
            when LEFT_ARROW
                choose_num--
                if choose_num == -1 then choose_num = @opt.length - 1
                @select_state(choose_num)
            when RIGHT_ARROW
                choose_num++
                if choose_num == @opt.length then choose_num = 0
                @select_state(choose_num)
            when ENTER_KEY
                i = choose_num
                @fade(i)
            when ESC_KEY
                destory_all()


class ComboBox extends Widget
    constructor: (@id, @on_click_cb) ->
        super
        @current_img = create_img("current_img", "", @element)
        
        if is_greeter
           
            de_current_id = localStorage.getItem("de_current_id")
            echo "-------------de_current_id:#{de_current_id}"
            if not de_current_id?
                echo "not de_current_id"
                de_current_id = DCore.Greeter.get_default_session() if is_greeter
                if de_current_id is null then de_current_id = "deepin"
                localStorage.setItem("de_current_id",de_current_id)
        else
            de_current_id = "shutdown"
        @menu = new MenuChoose("#{@id}_menuchoose")
        @menu.set_callback(@on_click_cb)

    insert: (id, title, img_normal,img_hover,img_click)->
        @menu.insert(id, title, img_normal,img_hover,img_click)
    
    frame_build:->
        @menu.frame_build()

    insert_noimg: (id, title)->
        @menu.insert_noimg(id, title)

    do_click: (e)->
        e.stopPropagation()
        echo "current_img do_click:#{@id}"
        if is_greeter
            if @menu.id is "power_menuchoose"
                $("#desktop_menuchoose").style.display = "none"
            else if @menu.id is "desktop_menuchoose"
                #if detect_is_from_lock() then return
                $("#power_menuchoose").style.display = "none"
        if !@menu.animation_end then return
        if @menu.element.style.display isnt "none"
            @menu.hide()
        else
            @menu.show()
    
    get_current: ->
        de_current_id = localStorage.getItem("de_current_id")
        @menu.current = de_current_id
        return @menu.current

    set_current: (id)->
        id = id.toLowerCase()
        try
            echo "set_current(id) :---------#{id}----------------"
            if @id is "desktop"
                icon = DCore.Greeter.get_session_icon(id)
                current_img_src = "images/desktopmenu/current/#{icon}.png"
                echo current_img_src
            else if @id is "power"
                current_img_src = "images/powermenu/#{id}.png"
            @current_img.src = current_img_src
        catch error
            echo "set_current(#{id}) error:#{error}"
            if @id is "desktop"
                current_img_error = "images/desktopmenu/current/unkown.png"
            else if @id is "power"
                current_img_error = "images/powermenu/powermenu.png"
            @current_img.src = current_img_error
        localStorage.setItem("de_current_id",id)
        @menu.current = id
        return id
