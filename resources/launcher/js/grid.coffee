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

applications = {}
category_infos = []

try_set_title = (el, text, width)->
    setTimeout(->
        height = calc_text_size(text, width)
        if height > 38
            el.setAttribute('title', text)
    , 200)

class Item extends Widget
    constructor: (@id, @core)->
        super
        create_img("", DCore.DEntry.get_icon(@core), @element)
        @name = create_element("div", "item_name", @element)
        @name.innerText = DCore.DEntry.get_name(@core)
        try_set_title(@element, DCore.DEntry.get_name(@core), 80)

    do_click : (e)->
        e?.stopPropagation()
        @element.style.cursor = "wait"
        DCore.DEntry.launch(@core, [])
        DCore.Launcher.exit_gui()

for core in DCore.Launcher.get_items()
    id = DCore.DEntry.get_id(core)
    applications[id] = new Item(id, core)
# load the Desktop Entry's infomations.

#export function
grid_show_items = (items) ->
    grid.innerHTML = ""
    for i in items
        grid.appendChild(applications[i].element)

show_grid_selected = (id)->
    cns = $s(".category_name")
    for c in cns
        if `id == c.getAttribute("cat_id")`
            c.setAttribute("class", "category_name category_selected")
        else
            c.setAttribute("class", "category_name")
        

grid = $('#grid')
grid_load_category = (cat_id) ->
    show_grid_selected(cat_id)
    if cat_id == -1
        grid.innerHTML = ""
        for own key, value of applications
            grid.appendChild(value.element)
        return

    if category_infos[cat_id]
        info = category_infos[cat_id]
    else
        info = DCore.Launcher.get_items_by_category(cat_id)
        category_infos[cat_id] = info

    grid_show_items(info)
    update_selected(null)
