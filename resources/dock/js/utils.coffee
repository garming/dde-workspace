itemDBus = (path)->
    name: "com.deepin.daemon.Dock"
    path: path
    interface: "dde.dock.EntryProxyer"

$DBus = {}

createItem = (d)->
    icon = d.Data[ITEM_DATA_FIELD.icon] || NOT_FOUND_ICON
    if !(icon.indexOf("data:") != -1 or icon[0] == '/' or icon.indexOf("file://") != -1)
        icon = DCore.get_theme_icon(icon, 48)

    title = d.Data[ITEM_DATA_FIELD.title] || "Unknow"

    if d.Type == ITEM_TYPE.app
        container = app_list.element

        $DBus[d.Id] = d
        console.log("AppItem #{d.Id}")
        new AppItem(d.Id, icon, title, container)
    else
        console.log("SystemItem #{d.Id}, #{icon}, #{title}")
        $DBus[d.Id] = d
        new SystemItem(d.Id, icon, title)


deleteItem = (id)->
    delete $DBus[id]
    # id = path.substr(path.lastIndexOf('/') + 1)
    i = Widget.look_up(id)
    if i
        i.destroy()
    else
        # console.log("#{id} not eixst")


bright_image = do ->
    brightnessCanvas = create_element(tag:'canvas', document.body)
    brightnessCanvas.width = brightnessCanvas.height = 48
    brightnessCanvas.style.position = 'absolute'
    brightnessCanvas.style.top = -screen.height
    (img, adjustment)->
        ctx = brightnessCanvas.getContext("2d")
        # clear the last icon.
        ctx.clearRect(0, 0, brightnessCanvas.width, brightnessCanvas.height)
        ctx.drawImage(img, 0, 0, brightnessCanvas.width, brightnessCanvas.height)
        origDataUrl = brightnessCanvas.toDataURL()
        dataUrl = DCore.Dock.bright_image(origDataUrl, adjustment)
        # i = new Image()
        # i.src = dataUrl
        # i.onload = ->
        #     ctx.drawImage(i, 0, 0)
        return dataUrl

updatePanel = ->
    _isDragging = false
    panel.updateWithAnimation()
    setTimeout(->
        panel.cancelAnimation()
    , 300)
