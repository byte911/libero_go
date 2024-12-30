-schema=widget_types
    version = 1.0

-types
    Widget:
        id: string
        type: WidgetType
        parent?: string
        children: [string]
        state: WidgetState
        style: Style
        layout: Layout
        handlers: [EventHandler]
        accessibility: Accessibility

    WidgetType:
        enum:
            - WINDOW
            - TOOLBAR
            - TAB_BAR
            - TAB
            - ADDRESS_BAR
            - BUTTON
            - MENU
            - MENU_ITEM
            - CONTEXT_MENU
            - DIALOG
            - POPUP
            - TOOLTIP
            - PROGRESS_BAR
            - STATUS_BAR

    WidgetState:
        visible: bool
        enabled: bool
        focused: bool
        hovered: bool
        pressed: bool
        selected: bool
        expanded: bool
        loading: bool
        error?: string

    Style:
        size: Size
        margin: Spacing
        padding: Spacing
        border: Border
        background: Background
        font: Font
        color: Color
        opacity: float
        shadow?: Shadow
        transform?: Transform

    Size:
        width: Dimension
        height: Dimension
        min_width?: int
        min_height?: int
        max_width?: int
        max_height?: int

    Dimension:
        type: DimensionType
        value: float

    DimensionType:
        enum:
            - PIXEL
            - PERCENTAGE
            - AUTO

    Spacing:
        top: int
        right: int
        bottom: int
        left: int

    Border:
        width: Spacing
        style: BorderStyle
        color: Color
        radius: Spacing

    BorderStyle:
        enum:
            - NONE
            - SOLID
            - DASHED
            - DOTTED
            - DOUBLE

    Background:
        color?: Color
        image?: string
        repeat?: string
        position?: string
        size?: string

    Font:
        family: string
        size: int
        weight: int
        style: FontStyle

    FontStyle:
        enum:
            - NORMAL
            - ITALIC
            - OBLIQUE

    Color:
        r: int
        g: int
        b: int
        a: float

    Shadow:
        offset_x: int
        offset_y: int
        blur: int
        spread: int
        color: Color

    Transform:
        translate?: Point
        rotate?: float
        scale?: Point
        skew?: Point

    Point:
        x: float
        y: float

    Layout:
        type: LayoutType
        direction: Direction
        align: Alignment
        justify: Justification
        wrap: bool
        gap: int

    LayoutType:
        enum:
            - FLOW
            - GRID
            - STACK

    Direction:
        enum:
            - HORIZONTAL
            - VERTICAL

    Alignment:
        enum:
            - START
            - CENTER
            - END
            - STRETCH

    Justification:
        enum:
            - START
            - CENTER
            - END
            - SPACE_BETWEEN
            - SPACE_AROUND

    EventHandler:
        event: string
        callback: function
        options?: {
            capture?: bool,
            passive?: bool,
            once?: bool
        }

    Accessibility:
        role: string
        label?: string
        description?: string
        keyboard_shortcut?: string
        tab_index?: int
        atomic?: bool
        busy?: bool
        live?: string
        relevant?: [string]
