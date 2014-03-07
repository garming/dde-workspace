#Copyright (c) 2011 ~ 2012 Deepin, Inc.
#              2011 ~ 2012 snyh
#
#Author:      snyh <snyh@snyh.org>
#Maintainer:  snyh <snyh@snyh.org>
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

Storage::setObject = (key, value) ->
    @setItem(key, JSON.stringify(value))

Storage::getObject = (key) ->
    JSON.parse(@getItem(key))

String::endsWith = (suffix)->
    return this.indexOf(suffix, this.length - suffix.length) != -1

String::args = ->
    o = this
    len = arguments.length
    for i in [1..len]
        o = o.replace(new RegExp("%" + i, "g"), "#{arguments[i - 1]}")

    return o

String::addSlashes = ->
    @replace(/[\\"']/g, '\\$&').replace(/\u0000/g, '\\0')

Array.prototype.remove = (el)->
    i = this.indexOf(el)
    if i != -1
        this.splice(this.indexOf(el), 1)[0]

# if typeof Object.clone != 'function'
#     Object::clone = ->
#         o = {}
#         for i of @
#             if @.hasOwnProperty(i)
#                 o[i] = @[i]
#         o
#
# Array::clone = (deep)->
#     deep = deep || false
#     if deep && typeof @[0] == 'object' && @[0].clone?
#         res = []
#         for i of @
#             res.push(i.clone())
#         res
#     else
#         @.slice(0)

echo = (log) ->
    console.log log

assert = (value, msg) ->
    if not value
        throw new Error(msg)

# xgettext will extract the first argument if two is given
# so, if domain is given, it ought to be the second argument.
_ = (s, d)->
    if d
        DCore.dgettext(d, s)
    else
        DCore.gettext(s)

bindtextdomain = (domain, locale_dir) ->
    DCore.bindtextdomain(domain, locale_dir)

build_menu = (info) ->
    len = info.length
    if len < 2
        return null
    count = 10000
    menu = new Menu(info[0])
    for i in [1...len]
        v = info[i]
        if v.length == 0  # separator
            menu.addSeparator()
        else if typeof v[0] == "number"
            item = new MenuItem(v[0], v[1])
            if v[2]?
                item.setActive(v[2])
            menu.append(item)
        else  # submenu
            echo "submenu"
            submenu = build_menu(v[1])
            menu.append(new MenuItem(count, v[1]).setSubMenu(build_menu(v[1])))
            count += 1

    return menu

get_page_xy = (el, x=0, y=0) ->
    p = webkitConvertPointFromNodeToPage(el, new WebKitPoint(x, y))

find_drag_target = (el)->
    p = el
    if p.draggable
        return p
    while p = p.parentNode
        if p.draggable
            return p
    return null

swap_element = (c1, c2) ->
    if c1.parentNode == c2.parentNode
        tmp = document.createElement('div')
        c1.parentNode.insertBefore(tmp, c1)
        c2.parentNode.insertBefore(c1, c2)
        tmp.parentNode.insertBefore(c2, tmp)
        tmp.parentNode.removeChild(tmp)

#disable default body drop event
document.body.ondrop = (e) -> e.preventDefault()

run_post = (f, self)->
    f2 = f.bind(self or this)
    setTimeout(f2, 0)

create_element = (opt, parent, compatible)->
    if typeof compatible != 'undefined' || typeof parent == 'string'
        opt = tag:opt, class: parent
        parent = compatible

    if not opt.tag?
        return null
    el = document.createElement(opt.tag)
    delete opt.tag
    for own k, v of opt
        el.setAttribute(k, v)

    if parent
        parent.appendChild(el)

    return el

create_img = (opt, parent, compatible)->
    if typeof compatible != 'undefined'
        opt = class:opt, src: parent
        parent = compatible
    opt.tag = 'img'
    el = create_element(opt, parent)
    el.draggable = false
    return el

calc_text_size = (txt, width)->
    tmp = create_element('div', 'hidden_calc_text', document.body)
    tmp.innerText = txt
    tmp.style.width = "#{width}px"
    h = tmp.clientHeight
    document.body.removeChild(tmp)
    return h

clamp = (value, min, max)->
    return min if value < min
    return max if value > max
    return value

get_function_name = ->
    return "AnymouseFunction" if not arguments.caller
    /function (.*?)\(/.exec(arguments.caller.toString())[1]


DEEPIN_ITEM_ID = "deepin-item-id"
dnd_is_desktop = (e)->
    return e.dataTransfer.getData("text/uri-list").trim().endsWith(".desktop")
dnd_is_deepin_item = (e)->
    if e.dataTransfer.getData(DEEPIN_ITEM_ID)
        return true
    else
        return false
dnd_is_file = (e)->
    return e.dataTransfer.getData("text/uri-list").length != 0

ajax = (url,sync=true,callback,callback_error) ->
    xhr = new XMLHttpRequest()

    xhr.open("GET", url, sync)

    xhr.onload = ->
        # echo "callback： #{typeof callback}"
        echo "XMLHttpRequest onload"
        callback?(xhr)
        return

    xhr.onerror = ->
        echo "XMLHttpRequest onerror"
        callback_error?(xhr)
    xhr.send(null)

get_path_base = (path)->
    path.split('/').slice(0, -1).join('/')
get_path_name = (path)->
    dot_pos = path.lastIndexOf('.')
    if dot_pos == -1
        path.substring(path.lastIndexOf('/') + 1)
    else
        path.substring(path.lastIndexOf('/') + 1, dot_pos)

remove_element = (obj)->
    _parentElement = obj?.parentNode
    _parentElement?.removeChild(obj)

sortNumber = (a , b) ->
    return a - b
array_sort_min2max = (arr) ->
    arr.sort(sortNumber)

inject_js = (src) ->
    js_element = create_element("script", null, document.body)
    js_element.src = src

inject_css = (el,src)->
    css_element = create_element('link', null, el)
    css_element.rel = "stylesheet"
    css_element.href = src

get_dbus = (type, opt)->
    type = type.toLowerCase()
    if type == "system"
        type = "sys"

    if typeof opt == 'string'
        opt = [opt]
        func = DCore.DBus[type]
    else
        opt = [opt.name, opt.path, opt.interface]
        func = DCore.DBus["#{type}_object"]

    d = null
    try
        for dump in [0..20]
            if (d = func.apply(null, opt))?
                break
    catch e
        throw "Get DBus \"#{opt.name} #{opt.path} #{opt.interface}\" failed: #{e}"
        return null

    if !d
        throw "Get DBus \"#{opt.name} #{opt.path} #{opt.interface}\" failed"
    d

