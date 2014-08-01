workareaTimer = null
HideMode =
    KeepShowing: 0
    KeepHidden: 1
    AutoHide: 2

HideModeNameMap =
    "keep-showing": 0
    "keep-hidden": 1
    "auto-hide": 2

class Setting
    constructor:->
        try
            @dbus = get_dbus(
                'session',
                name: "com.deepin.daemon.Dock",
                path: "/dde/dock/DockSetting",
                interface:"dde.dock.DockSetting",
                "GetHideMode"
            )
        catch e
            console.error("connect to DockSetting failed: #{e}")
            DCore.Dock.quit()

        @dbus.connect("HideModeChanged", (mode)=>
            console.log("mode changed to #{mode}")
            hideStatusManager.updateState()
        )

    hideMode:->
        mode = @dbus.GetHideMode_sync()
        if mode == "default" || mode == "intelligent"
            return HideMode.KeepShowing
        mode
    setHideMode:(id)->
        console.log("setHideMode: #{id}")
        @dbus.SetHideMode(id)
