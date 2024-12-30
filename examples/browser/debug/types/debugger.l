-schema=debugger_types
    version = 1.0

-import
    dom = "../../core/types/dom.l"
    css = "../../core/types/css.l"

-types
    DebuggerState:
        active: bool
        paused: bool
        breakpoints: [Breakpoint]
        call_stack: [StackFrame]
        watch_expressions: [WatchExpression]
        scope_chain: [Scope]

    Breakpoint:
        id: string
        type: BreakpointType
        location: SourceLocation
        condition?: string
        hit_count: int
        enabled: bool

    BreakpointType:
        enum:
            - LINE
            - EXCEPTION
            - DOM
            - XHR
            - EVENT
            - URL

    SourceLocation:
        url: string
        line_number: int
        column_number?: int

    StackFrame:
        id: string
        name: string
        source: SourceLocation
        scope_chain: [Scope]
        this_object: object

    Scope:
        type: ScopeType
        object: object
        name?: string
        start_location?: SourceLocation
        end_location?: SourceLocation

    ScopeType:
        enum:
            - GLOBAL
            - LOCAL
            - CLOSURE
            - CATCH
            - WITH
            - BLOCK

    WatchExpression:
        id: string
        expression: string
        result?: any

    DOMBreakpoint:
        node: dom.Node
        type: DOMBreakpointType
        enabled: bool

    DOMBreakpointType:
        enum:
            - SUBTREE_MODIFIED
            - ATTRIBUTE_MODIFIED
            - NODE_REMOVED

    EventBreakpoint:
        type: string
        category: string
        enabled: bool

    XHRBreakpoint:
        url: string
        enabled: bool

    ConsoleMessage:
        level: MessageLevel
        text: string
        source: SourceLocation
        timestamp: timestamp
        stack?: [StackFrame]

    MessageLevel:
        enum:
            - LOG
            - INFO
            - WARNING
            - ERROR

    DebuggerCommand:
        type: CommandType
        args?: object

    CommandType:
        enum:
            - CONTINUE
            - STEP_OVER
            - STEP_INTO
            - STEP_OUT
            - PAUSE
