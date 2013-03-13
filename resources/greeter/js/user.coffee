#Copyright (c) 2011 ~ 2012 Deepin, Inc.
#              2011 ~ 2012 yilang
#
#Author:      LongWei <yilang2007lw@gmail.com>
#                     <snyh@snyh.org>
#Maintainer:  LongWei <yilang2007lw@gmail.com>
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

apply_refuse_rotate = (el, time)->
    apply_animation(el, "refuse", "#{time}s", "linear")
    setTimeout(->
        el.style.webkitAnimation = ""
    , time * 1000)

class LoginEntry extends Widget
    constructor: (@id, @on_active)->
        super
        if DCore.Greeter.is_hide_users()
            @account = create_element("input", "Account", @element)
            @account.setAttribute("autofocus", "true")
            @account.addEventListener("keyup", (e)=>
                if e.which == 13
                    if not @account.value
                        @account.focus()
                    else
                        @password.focus()
            )

        @warning = create_element("div", "CapsWarning", @element)

        @password = create_element("input", "Password", @warning)
        @password.classList.add("PasswordStyle")
        @password.setAttribute("maxlength", 16)

        @password.addEventListener("keyup", (e)=>
            if e.which == 13
                if DCore.Greeter.is_hide_users()
                    if not @account.value
                        @account.focus()
                    else if not @password.value
                        @password.focus()
                    else
                        @on_active(@account.value, @password.value)
                else
                    if not @password.value
                        @password.focus()
                    else
                        @on_active(@id, @password.value)
        )

        @password.addEventListener("keypress", (e)=>
            keycode = e.KeyCode || e.which
            is_shift = e.shiftKey || (keycode == 16) || false

            if keycode >= 65 and keycode <= 90 and not is_shift
                #echo "capslock active and not shift"
                @warning.classList.add("CapsWarningBackground")
            else if keycode >=97 and keycode <= 122 and is_shift
                #echo "capslock active and shift"
                @warning.classList.add("CapsWarningBackground")
            else
                #echo "capslock inactive"
                @warning.classList.remove("CapsWarningBackground")
        )

        @login = create_element("button", "LoginButton", @element)
        @login.innerText = _("Log In")
        @login.addEventListener("click", =>
            if DCore.Greeter.is_hide_users()
                if not @account.value
                    @account.focus()
                else if not @password.value
                    @password.focus()
                else
                    @on_active(@account.value, @password.value)
            else
                if not @password.value
                    @password.focus()
                else
                    @on_active(@id, @password.value)
        )

        @element.setAttribute("autofocus", true)
        if DCore.Greeter.is_hide_users()
            @account.index = 0
            @password.index = 1
            @login.index = 2
            @account.focus()
        else
            @password.index = 0
            @login.index = 1
            @password.focus()

class Loading extends Widget
    constructor: (@id)->
        super
        create_element("div", "ball", @element)
        create_element("div", "ball1", @element)
        create_element("span", "", @element).innerText = _("Welcome")

_default_bg_src = "/usr/share/backgrounds/1440x900.jpg"
_current_bg = create_img("Background", _default_bg_src)
document.body.appendChild(_current_bg)

_current_user = null
userinfo_list = []
_drag_flag = false

class UserInfo extends Widget
    constructor: (@id, name, img_src)->
        super
        @li = create_element("li", "")
        @li.appendChild(@element)
        @userbase = create_element("div", "UserBase", @element)
        @img = create_img("UserImg", img_src, @userbase)
        @name = create_element("div", "UserName", @userbase)
        @name.innerText = name
        @login_displayed = false
        @index = roundabout.childElementCount
        userinfo_list.push(@)

        if @id == "guest"
            user_bg = _default_bg_src
        else
            try
                user_bg = DCore.Greeter.get_user_background(@id)
            catch error
                user_bg = _default_bg_src

        if user_bg == "nonexists"
            user_bg = _default_bg_src
        @background = create_img("Background", user_bg)
        @element.index = 0

    focus: ->
        _current_user?.blur()
        _current_user = @
        $("#roundabout").focus()
        @element.focus()
        @add_css_class("UserInfoSelected")

        if DCore.Greeter.in_authentication()
            DCore.Greeter.cancel_authentication()

        if DCore.Greeter.is_hide_users()
            DCore.Greeter.start_authentication("*other")
        else
            if @background.src != _current_bg.src
                document.body.appendChild(@background)
                document.body.removeChild(_current_bg)
                _current_bg = @background

            DCore.Greeter.set_selected_user(@id)
            if @id != "guest"
                session = DCore.Greeter.get_user_session(@id)
                if session?
                    if session != "nonexists"
                        de_menu.set_current(session)
                        DCore.Greeter.set_selected_session(session)

            DCore.Greeter.start_authentication(@id)

    blur: ->
        @element.setAttribute("class", "UserInfo")
        @login?.destroy()
        @login = null
        @loading?.destroy()
        @loading = null
        @login_displayed = false
        if DCore.Greeter.in_authentication()
            DCore.Greeter.cancel_authentication()

    show_login: ->
        if false
            @login()
        else if _drag_flag
            echo "in drag"

        else if _current_user == @ and not @login
            @login = new LoginEntry("login", (u, p)=>@on_verify(u, p))
            @element.appendChild(@login.element)
            if DCore.Greeter.is_hide_users()
                @element.style.paddingBottom = "0px"
                @login.account.focus()
            else
                @login.password.focus()

            if @name.innerText == "guest"
                @login.password.style.display = "none"
                @login.password.value = "guest"

            @login_displayed = true
            @add_css_class("UserInfoSelected")
            @add_css_class("foo")

    hide_login: ->
        if @login and @login_displayed
            @blur()
            @focus()

    do_click: (e)->
        if _current_user == @
            if not @login and not @in_drag
                @show_login()
            else
                if e.target.parentElement.className == "LoginEntry" or e.target.parentElement.className == "CapsWarning"
                    echo "login pwd clicked"
                else
                    @hide_login()
        else
            @focus()

    animate_prev: ->
        echo "animate prev"
        if @index is 0
            prev_index = _counts - 1 
        else
            prev_index = @index - 1

        setTimeout( ->
                userinfo_list[prev_index].focus()
                return true
            ,200)
        jQuery("#roundabout").roundabout("animateToChild", prev_index)

    animate_next: ->
        echo "animate next"
        if @index is _counts - 1
            next_index = 0
        else
            next_index = @index + 1

        setTimeout( ->
                userinfo_list[next_index].focus()
                return true
            ,200)
        jQuery("#roundabout").roundabout("animateToChild", next_index)

    animate_near: ->
        echo "animate near"
        try
            near_index = jQuery("#roundabout").roundabout("getNearestChild")
        catch error
            echo "getNeareastChild error"

        if near_index is false
            near_index = @index

        setTimeout( ->
                userinfo_list[near_index].focus()
                _drag_flag = false
                return true
            ,200)
        jQuery("#roundabout").roundabout("animateToChild", near_index)

    on_verify: (username, password)->
        @login.destroy()
        @loading = new Loading("loading")
        @element.appendChild(@loading.element)

        DCore.Greeter.set_selected_session(de_menu.get_useable_current()[0])
        if DCore.Greeter.is_hide_users()
            DCore.Greeter.set_selected_user(username)
            DCore.Greeter.login_clicked(username)
            DCore.signal_connect("prompt", (msg)->
                DCore.Greeter.login_clicked(password)
            )
        else
            DCore.Greeter.login_clicked(password)
        #debug code begin
        #div_auth = create_element("div", "", $("#Debug"))
        #div_auth.innerText += "authenticate"

        #debug code end

# below code should use c-backend to fetch data
if DCore.Greeter.is_hide_users()
    u = new UserInfo("*other", "", "images/huser.jpg")
    roundabout.appendChild(u.li)
    Widget.look_up("*other").element.style.paddingBottom = "5px"
    u.focus()
else
    users = DCore.Greeter.get_users()
    echo users
    for user in users
        if user == DCore.Greeter.get_default_user()
            try
                user_image = DCore.Greeter.get_user_image(user)
            catch error
                echo "get user image failed"
            if not user_image? or user_image == "nonexists"
                try
                    user_image = DCore.DBus.sys_object("com.deepin.passwdservice", "/", "com.deepin.passwdservice").get_user_fake_icon_sync(user)
                catch error
                    user_image = "images/guest.jpg"
    
            u = new UserInfo(user, user, user_image) 
            roundabout.appendChild(u.li)
            u.focus()

    if DCore.Greeter.is_support_guest()
        u = new UserInfo("guest", "guest", "images/guest.jpg")
        roundabout.appendChild(u.li)
        if DCore.Greeter.is_guest_default()
            u.focus()

    for user in users
        if user == DCore.Greeter.get_default_user()
            echo "already append default user"
        else
            try
                user_image = DCore.Greeter.get_user_image(user)
            catch error
                echo "get user image failed"
            if not user_image? or user_image == "nonexists"
                try
                    user_image = DCore.DBus.sys_object("com.deepin.passwdservice", "/", "com.deepin.passwdservice").get_user_fake_icon_sync(user)
                catch error
                    user_image = "images/guest.jpg"

            u = new UserInfo(user, user, user_image) 
            roundabout.appendChild(u.li)

DCore.signal_connect("message", (msg) ->
    echo msg.error
)

DCore.signal_connect("auth", (msg) ->
    user = _current_user
    user.focus()
    user.show_login()
    if DCore.Greeter.is_hide_users()
        user.login.account.style.color = "red"
        user.login.account.value = msg.error
        user.login.account.blur()
        if DCore.Greeter.in_authentication()
            DCore.Greeter.cancel_authentication()
        user.login.account.addEventListener("focus", (e)=>
            user.login.account.style.color = "black"
            user.login.account.value = ""
            DCore.Greeter.start_authentication("*other")
        )
    else
        user.login.password.classList.remove("PasswordStyle")
        user.login.password.style.color = "red"
        user.login.password.value = msg.error
        user.login.password.blur()
        if DCore.Greeter.in_authentication()
            DCore.Greeter.cancel_authentication()
        user.login.password.addEventListener("focus", (e)=>
            user.login.password.classList.add("PasswordStyle")
            user.login.password.style.color ="black"
            user.login.password.value = ""
        )

        document.body.addEventListener("keydown", (e) =>
            if user? and user.login_displayed
                if e.which == 13
                    user.login.password.focus()
        )

    apply_refuse_rotate(user.element, 0.5)
)

_counts = roundabout.childElementCount

document.body.addEventListener("mousewheel", (e) =>

    if e.wheelDelta > 100
        #echo "scroll to prev"
        _current_user?.animate_prev()

    if e.wheelDelta < -100
        #echo "scroll to next"
        _current_user?.animate_next()
)

document.body.addEventListener("keydown", (e)=>

    if e.which == 37
        #echo "prev"
        _current_user?.animate_prev()

    else if e.which == 39 
        #echo "next"
        _current_user?.animate_next()

    else if e.which == 13 
        #echo "enter"
        _current_user?.show_login()

    else if e.which == 27
        #echo "esc"
        _current_user?.hide_login()
)

if roundabout.children.length <= 2
    roundabout.style.width = "0"
    Widget.look_up(roundabout.children[0].children[0].getAttribute("id"))?.show_login()

run_post(->
    l = (screen.width  - roundabout.clientWidth) / 2
    roundabout.style.left = "#{l}px"
)

jQuery("#roundabout").drag("start", (ev, dd) ->
    _current_user?.hide_login()
    _drag_flag = true
, {distance:100} 
)

jQuery("#roundabout").drag("end", (ev, dd) ->
    _current_user?.animate_near()
)

