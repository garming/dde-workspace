#Copyright (c) 2011 ~ 2012 Deepin, Inc.
#              2011 ~ 2012 bluth
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

class CityMoreMenu extends Widget
    constructor: (x,y)->
        super
        @id = "CityMoreMenu"
        @element.style.left = x 
        @element.style.top = y 
        @element.style.display = "none"
        @element.style.zIndex = 65535

    do_click:(e)->
        echo "do_click"
        clearTimeout(@display_city_menu_id) if @display_city_menu_id
        e.stopPropagation()
        return

    show_hide_position:(bottom_distance)=>
        if @element.style.display == "none"
            if bottom_distance < 200
                @element.style.top = -252
            else @element.style.top = 84
            @element.style.display = "block"
            @display_city_menu_id = setTimeout( =>
                @element.style.display = "none"
            ,4000)
        else
            @element.style.display = "none"
            clearTimeout(@display_city_menu_id) if @display_city_menu_id
        return @display_city_menu_id
    display_none:->
        @element.style.display = "none"
    clearTimeout_display:->
        clearTimeout(@display_city_menu_id) if @display_city_menu_id
    more_city_build: ->
        @str_provinit = "--" + _("province") + "--"
        @str_cityinit = "--" + _("city") + "--" 
        @str_distinit = "--" + _("county") + "--"
        @chooseprov = create_element("select", "chooseprov", @element)
        @choosecity = create_element("select", "choosecity", @element)
        @choosedist = create_element("select", "choosedist", @element)

        @clearOptions(@chooseprov)
        provinit = create_element("option","provinit",@chooseprov)
        provinit.innerText = @str_provinit
        provinit.selected = "true"
        i = 0
        @chooseprov.options.add(new Option(cities[i].name, cities[i++].id)) while i < cities.length
        length = @chooseprov.options.length
        @chooseprov.size = if length < 13 then length else 13
        
        @choosecity.size = 1
        @clearOptions(@choosecity)
        cityinit = create_element("option", "cityinit", @choosecity)
        cityinit.innerText = @str_cityinit
        cityinit.selected = "true"
        
        @choosedist.size = 1
        @clearOptions(@choosedist)
        distinit = create_element("option", "distinit", @choosedist)
        distinit.innerText = @str_distinit
        distinit.selected = "true"

    change_chooseprov: (callback)->
        @chooseprov.addEventListener("change", =>
            provIndex = @chooseprov.selectedIndex
            if provIndex == -1
                @chooseprov.options.remove(provIndex)
            else
                provvalue = @chooseprov.options[provIndex].value 
                if provvalue != @str_provinit
                    data = @read_data_from_json(provvalue,callback)
            )

    read_data_from_json: (id,callback) -> 
        url = "city/" + id + ".json"
        ajax(url,(xhr)=>
            if xhr.responseText != "" && xhr.responseText != null
                data = JSON.parse(xhr.responseText)
                @cityadd(data[id].data,callback)
        ,false)

    cityadd: (data,callback) ->
        @clearOptions(@choosecity)#1
        for i of data
            @choosecity.options.add(new Option(data[i].name, i))
        length = @choosecity.options.length
        @choosecity.size = if length < 13 then length else 13 
        @choosecity.onchange = =>
            cityIndex = @choosecity.selectedIndex
            if cityIndex == -1
                @choosecity.options.remove(cityIndex)
            else
                cityvalue = @choosecity.options[cityIndex].value
                if cityvalue != @str_cityinit
                    @distadd(data[cityvalue].data,callback)
    
    distadd: (data,callback) ->
        @clearOptions(@choosedist)#1
        for i of data
            @choosedist.options.add(new Option(data[i].name, i))
        length = @choosedist.options.length
        @choosedist.size = if length < 13 then length else 13
        @choosedist.onchange = =>
            clearInterval(@auto_update_cityid_choose)
            @element.style.display = "none"
            distIndex = @choosedist.selectedIndex
            if distIndex == -1
                @choosedist.options.remove(distIndex)
            else
                distvalue = @choosedist.options[distIndex].value
                if distvalue != @str_distinit
                    cityid_choose = data[distvalue].data
                    localStorage.setItem("cityid_storage",cityid_choose)
                    callback()
    clearOptions:(colls)->
        colls.remove(i) for i in colls.length 
