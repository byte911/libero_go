-schema=dom_types
    version = 1.0

-types
    Node:
        id: string
        type: NodeType
        name?: string
        value?: string
        attributes: {string: string}
        parent?: Node
        children: [Node]
        style: ComputedStyle
        events: [EventListener]

    NodeType:
        enum:
            - ELEMENT_NODE
            - TEXT_NODE
            - COMMENT_NODE
            - DOCUMENT_NODE
            - DOCUMENT_TYPE_NODE
            - DOCUMENT_FRAGMENT_NODE

    Element:
        extends: Node
        tag_name: string
        namespace: string
        class_list: [string]
        dataset: {string: string}
        computed:
            is_form_element = tag_name in ["input", "select", "textarea", "button"]
            is_void_element = tag_name in ["img", "br", "hr", "input", "meta", "link"]

    Document:
        extends: Node
        doctype: DocumentType
        root: Element
        head: Element
        body: Element
        forms: [Element]
        images: [Element]
        links: [Element]
        scripts: [Element]

    DocumentType:
        name: string
        public_id: string
        system_id: string

    EventListener:
        event_type: string
        callback: string  # JavaScript function reference
        capture: bool
        passive: bool
        once: bool

    ComputedStyle:
        display: string
        position: string
        width: Dimension
        height: Dimension
        margin: BoxDimensions
        padding: BoxDimensions
        border: BoxDimensions
        background: Background
        color: Color
        font: Font
        computed:
            is_visible = display != "none"
            is_positioned = position in ["relative", "absolute", "fixed"]

    Dimension:
        value: float
        unit: string  # px, em, rem, %, etc.
        computed:
            in_pixels = convert_to_pixels(value, unit)

    BoxDimensions:
        top: Dimension
        right: Dimension
        bottom: Dimension
        left: Dimension

    Background:
        color: Color
        image?: string
        repeat: string
        position: Position
        size: Size

    Color:
        red: int
        green: int
        blue: int
        alpha: float
        constraints:
            - red between 0 and 255
            - green between 0 and 255
            - blue between 0 and 255
            - alpha between 0 and 1

    Font:
        family: [string]
        size: Dimension
        weight: int
        style: string
        line_height: Dimension
