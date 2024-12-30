-schema=window_types
    version = 1.0

-import
    widget = "./widget.l"

-types
    Window:
        id: string
        type: WindowType
        state: WindowState
        bounds: Bounds
        widgets: [widget.Widget]

    WindowType:
        enum:
            - NORMAL
            - POPUP
            - PANEL
            - DEVTOOLS
            - MINIMIZED
            - FULLSCREEN

    WindowState:
        active: bool
        minimized: bool
        maximized: bool
        fullscreen: bool
        always_on_top: bool

    Bounds:
        x: int
        y: int
        width: int
        height: int

    Screen:
        id: string
        bounds: Bounds
        work_area: Bounds
        scale_factor: float
        rotation: int
        primary: bool

    Display:
        screen: Screen
        color_depth: int
        color_space: string
        refresh_rate: float

    WindowManager:
        active_window?: string
        windows: [Window]
        displays: [Display]

    WindowAnimation:
        type: AnimationType
        duration: int
        timing: TimingFunction
        delay?: int

    AnimationType:
        enum:
            - NONE
            - FADE
            - SLIDE
            - SCALE
            - ROTATE

    TimingFunction:
        enum:
            - LINEAR
            - EASE
            - EASE_IN
            - EASE_OUT
            - EASE_IN_OUT
