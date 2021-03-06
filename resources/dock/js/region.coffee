calc_app_item_size = ->
    return if IN_INIT
    # TODO:
    # calc when added/removed
    #systemTray?.updateTrayIcon()
    apps = $s(".AppItem")
    return if apps.length == 0

    container = $("#container")
    list_width = container.clientWidth
    container_list = container.children
    item_num = 0
    for i in [0...container_list.length]
        item_num += container_list[i].children.length
    client_width = $("#containerWrap").clientWidth
    w = clamp(client_width / item_num, 34, ITEM_WIDTH * MAX_SCALE)
    ICON_SCALE = clamp(w / ITEM_WIDTH, 0, MAX_SCALE)

    for i in apps
        # Widget.look_up(i.id)?.update_scale()

        h = w * (ITEM_HEIGHT / ITEM_WIDTH)
        # apps are moved up, so add 8

    height = h * (ITEM_HEIGHT - BOARD_IMG_MARGIN_BOTTOM) / ITEM_HEIGHT + BOARD_IMG_MARGIN_BOTTOM * ICON_SCALE + 8

    # update_dock_region($("#container").clientWidth)
    if panel
        panel.set_width(Panel.getPanelMiddleWidth())

# update_dock_region = do ->
#     updateRegionTimer = null
#     (w, h)->
#         clearTimeout(updateRegionTimer)
#         updateRegionTimer = setTimeout(->
#             do_update_dock_region(w,h)
#         , 0)

# do_update_dock_region = do->
update_dock_region = do->
    lastWidth = null
    (w, h)->
        # console.warn("do_update_dock_region")
        settings?.updateSize(settings.displayMode())
        h = DOCK_HEIGHT unless h?
        if w
            lastWidth = w
        else if lastWidth
            w = lastWidth
        apps = $s(".AppItem")
        if apps.length > 0
            if w
                app_len = w
            else
                app_len = ITEM_WIDTH * apps.length
            panel_width = Panel.getPanelWidth()
            switch settings.displayMode()
                when DisplayMode.Efficient, DisplayMode.Classic
                    left_offset = 0
                when DisplayMode.Fashion
                    left_offset = (screen.width - app_len) / 2
            DCore.Dock.force_set_region(left_offset, 0, w, panel_width, h)
        else
            console.warn("[update_dock_region] $s('.AppItem').length == 0")

_b.onresize = ->
    calc_app_item_size()
    if debugRegion
        console.warn("[body.onresize] update_dock_region")
    update_dock_region($("#container").clientWidth)

clearRegion = ->
    DCore.Dock.set_is_hovered(false)
    if debugRegion
        console.warn("[clearRegion] update_dock_region")
    update_dock_region()


listenInvalidIdSignal = ->
    dbus = DCore.DBus.session_object(
        "com.deepin.daemon.Dock",
        "/dde/dock/XMouseAreaProxyer",
        "dde.dock.XMouseAreaProxyer"
    )

    dbus?.connect("InvalidId", ->
        # console.log("InvalidId")
        update_dock_region()
        hideStatusManager.setState(hideStatusManager.state)
    )
