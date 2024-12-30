-schema=debugger_types
    version = 1.0

-types
    Debugger:
        id: string
        target: DebugTarget
        state: DebuggerState
        breakpoints: [Breakpoint]
        watches: [WatchExpression]

    DebugTarget:
        type: TargetType
        identifier: string
        context?: object

    TargetType:
        enum:
            - PROCESS
            - THREAD
            - TAB
            - FRAME
            - WORKER

    DebuggerState:
        status: DebugStatus
        current_frame?: StackFrame
        reason?: string

    DebugStatus:
        enum:
            - RUNNING
            - PAUSED
            - STOPPED
            - ERROR

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

    SourceLocation:
        file: string
        line: int
        column?: int
        function?: string

    WatchExpression:
        id: string
        expression: string
        result?: EvaluationResult

    StackFrame:
        id: string
        name: string
        source: SourceLocation
        scope: [ScopeChain]
        this?: object

    ScopeChain:
        type: ScopeType
        name: string
        variables: [Variable]

    ScopeType:
        enum:
            - GLOBAL
            - LOCAL
            - CLOSURE
            - CATCH
            - WITH

    Variable:
        name: string
        value: any
        type: string
        properties?: [Property]

    Property:
        name: string
        value: any
        type: string
        enumerable: bool

    EvaluationResult:
        value: any
        type: string
        objectId?: string
        subtype?: string

    DebuggerCommand:
        type: CommandType
        args?: object
        context?: object

    CommandType:
        enum:
            - CONTINUE
            - STEP_OVER
            - STEP_INTO
            - STEP_OUT
            - PAUSE
            - EVALUATE

    ExceptionInfo:
        type: string
        message: string
        stack?: [StackFrame]
        data?: object

    DebugEvent:
        type: EventType
        data: object
        timestamp: timestamp

    EventType:
        enum:
            - BREAK
            - EXCEPTION
            - CONSOLE
            - OUTPUT

    ConsoleMessage:
        type: MessageType
        text: string
        source: SourceLocation
        timestamp: timestamp

    MessageType:
        enum:
            - LOG
            - INFO
            - WARN
            - ERROR

    DebugSession:
        id: string
        start_time: timestamp
        end_time?: timestamp
        events: [DebugEvent]
        breakpoints: [Breakpoint]

    DebugReport:
        session_id: string
        duration: int
        events: [DebugEvent]
        exceptions: [ExceptionInfo]
        console: [ConsoleMessage]
