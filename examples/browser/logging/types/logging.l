-schema=logging_types
    version = 1.0

-types
    Logger:
        id: string
        name: string
        level: LogLevel
        handlers: [LogHandler]
        filters: [LogFilter]

    LogLevel:
        enum:
            - TRACE
            - DEBUG
            - INFO
            - WARN
            - ERROR
            - FATAL

    LogHandler:
        type: HandlerType
        formatter: LogFormatter
        config: HandlerConfig

    HandlerType:
        enum:
            - CONSOLE
            - FILE
            - NETWORK
            - DATABASE
            - MEMORY

    LogFormatter:
        pattern: string
        timezone?: string
        locale?: string

    HandlerConfig:
        level?: LogLevel
        buffer_size?: int
        max_size?: int
        rotation?: RotationPolicy

    RotationPolicy:
        interval?: string
        max_files?: int
        max_size?: int
        compress?: bool

    LogFilter:
        type: FilterType
        config: FilterConfig

    FilterType:
        enum:
            - LEVEL
            - PATTERN
            - CONTEXT
            - RATE

    FilterConfig:
        pattern?: string
        context?: object
        rate?: RateLimit

    RateLimit:
        count: int
        interval: int

    LogRecord:
        timestamp: timestamp
        level: LogLevel
        logger: string
        message: string
        context?: object
        trace?: StackTrace

    StackTrace:
        frames: [StackFrame]
        exception?: string

    StackFrame:
        file: string
        line: int
        function: string
        module?: string

    LogContext:
        session_id?: string
        request_id?: string
        user_id?: string
        component?: string
        tags?: [string]

    LogBatch:
        id: string
        records: [LogRecord]
        metadata: BatchMetadata

    BatchMetadata:
        timestamp: timestamp
        count: int
        source: string

    LogQuery:
        timerange: {
            start: timestamp,
            end: timestamp
        }
        levels?: [LogLevel]
        patterns?: [string]
        context?: object

    LogStats:
        total: int
        by_level: {string: int}
        by_logger: {string: int}
        errors: int

    LogReport:
        id: string
        timestamp: timestamp
        duration: int
        stats: LogStats
        trends: [LogTrend]
        alerts: [LogAlert]

    LogTrend:
        metric: string
        values: [TrendPoint]
        analysis: string

    TrendPoint:
        timestamp: timestamp
        value: float

    LogAlert:
        level: LogLevel
        message: string
        count: int
        first_seen: timestamp
        last_seen: timestamp
