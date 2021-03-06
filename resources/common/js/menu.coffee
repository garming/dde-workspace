DEEPIN_MENU_NAME = "com.deepin.menu"
DEEPIN_MENU_PATH = "/com/deepin/menu"
DEEPIN_MENU_INTERFACE = "com.deepin.menu.Menu"
DEEPIN_MENU_MANAGER_INTERFACE = "com.deepin.menu.Manager"


DEEPIN_MENU_TYPE =
    NORMAL: 0
    CHECKBOX: 1
    RADIOBOX: 2


DEEPIN_MENU_CORNER_DIRECTION =
    UP: "up"
    DOWN: "down"
    LEFT: "left"
    RIGHT: "right"


getMenuManager = ->
    return get_dbus(
        "session",
        name:DEEPIN_MENU_NAME,
        path:DEEPIN_MENU_PATH,
        interface:DEEPIN_MENU_MANAGER_INTERFACE,
        "RegisterMenu"
    )


class NormalMenu
    constructor: (items...)->
        @x = 0
        @y = 0
        @isDockMenu = false
        @cornerDirection = DEEPIN_MENU_CORNER_DIRECTION.DOWN
        if items.length == 1 and Array.isArray(items[0])
            @menuJsonContent = new MenuContent(items[0])
        else
            @menuJsonContent = new MenuContent(items)

    apply: (fn, items)->
        MenuContent.prototype[fn].apply(@menuJsonContent, items)

    append: (items...)->
        @apply("append", items)

    addSeparator: ->
        @menuJsonContent.addSeparator()

    toString: ->
        "{\"x\": #{@x}, \"y\": #{@y}, \"isDockMenu\": #{@isDockMenu}, \"cornerDirection\": \"#{@cornerDirection}\", \"menuJsonContent\": \"#{@menuJsonContent.toString().addSlashes()}\"}"


class MenuContent
    constructor: (item...)->
        @checkableMenu = false
        @singleCheck = false
        @items = []
        if item.length == 1 and Array.isArray(item[0])
            MenuContent::append.apply(@, item[0])
        else
            MenuContent::append.apply(@, item)

    append: (items...)->
        items.forEach((el) =>
            @items.push(el)
        )
        @

    addSeparator: ->
        @append(new MenuSeparator())

    toString:->
        JSON.stringify(@)


class CheckBoxMenu extends NormalMenu
    constructor:->
        super
        @menuJsonContent.checkableMenu = true


class RadioBoxMenu extends CheckBoxMenu
    constructor:->
        super
        @menuJsonContent.singleCheck = true


class MenuItem
    constructor: (itemId, @itemText, subMenu=null)->
        @itemId = "#{itemId}"
        @isCheckable = false
        @checked = false
        @itemIcon = ''
        @itemIconHover = ''
        @isActive = true
        @itemIconInactive = ""
        @showCheckmark = true
        if subMenu == null
            @itemSubMenu = new MenuContent
        else
            @itemSubMenu = subMenu.menu.menuJsonContent

    setIcon: (icon)->
        @itemIcon = icon
        @

    setHoverIcon: (icon)->
        @itemIconHover = icon
        @

    setInactiveIcon: (icon)->
        @itemIconInactive = icon
        @

    setSubMenu: (subMenu)->
        @itemSubMenu = subMenu.menu.menuJsonContent
        @

    setActive: (isActive)->
        @isActive = isActive
        @

    setShowCheckmark: (showCheckmark)->
        @showCheckmark = showCheckmark
        @

    toString: ->
        JSON.stringify(@)


class CheckBoxMenuItem extends MenuItem
    constructor: (itemId, itemText, checked=false, isActive=true)->
        super(itemId, itemText)
        @isCheckable = true
        @setChecked(checked)

    setChecked: (checked)->
        @checked = checked
        @


class RadioBoxMenuItem extends CheckBoxMenuItem


class MenuSeparator extends MenuItem
    constructor: ->
        super('', '')


class Menu
    constructor: (@type, items...)->
        switch @type
            when DEEPIN_MENU_TYPE.NORMAL
                @menu = new NormalMenu(items)
            when DEEPIN_MENU_TYPE.CHECKBOX
                @menu = new CheckBoxMenu(items)
            when DEEPIN_MENU_TYPE.RADIOBOX
                @menu = new RadioBoxMenu(items)
            else
                throw "Invalid DEEPIN_MENU_TYPE: #{@type}"
        @dbus = null

    apply: (fn, items)->
        switch @menu.constructor.name
            when "NormalMenu"
                NormalMenu.prototype[fn].apply(@menu, items)
            when "CheckBoxMenu"
                CheckBoxMenu.prototype[fn].apply(@menu, items)
            when "RadioBoxMenu"
                RadioBoxMenu.prototype[fn].apply(@menu, items)
        @

    append: (items...)->
        @apply("append", items)

    addSeparator: ->
        @menu.addSeparator()
        @

    setDockMenuCornerDirection: (cornerDirection)->
        @menu.cornerDirection = cornerDirection
        @

    _init_dbus: ->
        try
            manager = getMenuManager()
        catch e
            console.log("get menu manager failed: #{e}")
            return

        @menu_dbus_path = manager.RegisterMenu_sync()
        console.debug "menu path is: #{@menu_dbus_path}"
        try
            @dbus = get_dbus(
                "session",
                name:DEEPIN_MENU_NAME,
                path:@menu_dbus_path,
                interface:DEEPIN_MENU_INTERFACE,
                "ShowMenu"
            )
        catch e
            @dbus = null
            console.log("get deepin dbus menu failed: #{e}")

    addListener: (@callback)->
        #warning:here to _init_dbus instead of in constructor
        #To avoid too many @dbus of subMenu which will be destroyed by Deepin_Menu
        @_init_dbus() if not @dbus?
        try
            @dbus?.connect("ItemInvoked", @callback)
            @
        catch e
            echo "listenItemSelected: #{e}"

    unregisterHook: (fn)->
        @_init_dbus() if not @dbus?
        @dbus?.connect("MenuUnregistered", fn)
        @

    showMenu: (x, y, ori=null)->
        @_init_dbus() if not @dbus?
        @menu.x = x
        @menu.y = y
        if ori != null
            # console.log("#{ori}")
            @menu.isDockMenu = true
            @menu.cornerDirection = ori
        # echo @menu
        @dbus?.ShowMenu("#{@menu}")
        @

    toString: ->
        "#{@menu}"

    destroy: ->
        try
            @dbus?.dis_connect("ItemInvoked", @callback)

    unregister:->
        @destroy()
        getMenuManager()?.UnregisterMenu(@menu_dbus_path)
