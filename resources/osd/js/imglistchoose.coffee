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
class ImgListChoose extends ListChoose
    LI_SIZE =
        w:100
        h:64

    constructor:(@id)->
        super

    ListAllBuild:(@list,@current,@img_src = "img",@img_type = "png") ->
        @length = @list.length
        @img_srcs = []
        @img_srcs_hover = []
        @li_img = []
        @li_text = []
        inject_css(@element,"css/imglistchoose.css")
        @Listul = create_element("div","Img_listul",@element)
        for each,i in @list
            @li[i] = create_element("div","Img_li",@Listul)
            @li[i].setAttribute("id",each.name)
            @li[i].style.width = LI_SIZE.w
            @li[i].style.height = LI_SIZE.h
            @img_srcs[i] = "#{@img_src}/#{each.img}.#{@img_type}"
            @img_srcs_hover[i] = "#{@img_src}/#{each.img}_hover.#{@img_type}"
            @li_img[i] = create_img("Img_li_img",@img_srcs[i],@li[i])
            @li_text[i] = create_element("div","Img_li_text",@li[i])
            @li_text[i].innerText = each.name
            @currentIndex = i if each is @current 
        @setCurrentCss()

    selectCss: (i)=>
        @li_img[i].src = @img_srcs_hover[i]
        @li_text[i].style.color = "#01bdff"

    unselectCss: (i) =>
        @li_img[i].src = @img_srcs[i]
        @li_text[i].style.color = "#FFF"