-schema=error_types
    version = 1.0

-types
    Error:
        id: string
        type: ErrorType
        severity: ErrorSeverity
        message: string
        details: ErrorDetails
        context: ErrorContext

    ErrorType:
        enum:
            - RUNTIME
            - NETWORK
            - SECURITY
            - RESOURCE
            - VALIDATION
            - BUSINESS
            - SYSTEM

    ErrorSeverity:
        enum:
            - CRITICAL
            - HIGH
            - MEDIUM
            - LOW
            - INFO

    ErrorDetails:
        code: string
        source: string
        stack?: StackTrace
        cause?: Error
        data?: object

    ErrorContext:
        timestamp: timestamp
        component: string
        session?: string
        user?: string
        environment: string

    StackTrace:
        frames: [StackFrame]
        async?: bool

    StackFrame:
        file: string
        line: int
        column: int
        function: string
        arguments?: [string]

    ErrorHandler:
        id: string
        type: HandlerType
        config: HandlerConfig
        actions: [ErrorAction]

    HandlerType:
        enum:
            - RETRY
            - RECOVER
            - FALLBACK
            - NOTIFY
            - LOG

    HandlerConfig:
        max_retries?: int
        retry_delay?: int
        timeout?: int
        fallback?: object

    ErrorAction:
        type: ActionType
        config: ActionConfig
        priority: int

    ActionType:
        enum:
            - NOTIFY_USER
            - SEND_ALERT
            - LOG_ERROR
            - COLLECT_DATA
            - CLEANUP

    ActionConfig:
        template?: string
        channels?: [string]
        data?: object

    ErrorPolicy:
        id: string
        patterns: [ErrorPattern]
        handlers: [ErrorHandler]
        priority: int

    ErrorPattern:
        type?: ErrorType
        severity?: ErrorSeverity
        codes?: [string]
        sources?: [string]

    ErrorMetrics:
        total: int
        by_type: {string: int}
        by_severity: {string: int}
        by_source: {string: int}
        trends: [ErrorTrend]

    ErrorTrend:
        type: string
        period: string
        counts: [TrendPoint]

    TrendPoint:
        timestamp: timestamp
        count: int

    ErrorReport:
        id: string
        timestamp: timestamp
        duration: int
        metrics: ErrorMetrics
        top_errors: [ErrorSummary]
        recommendations: [ErrorRecommendation]

    ErrorSummary:
        error_type: string
        count: int
        first_seen: timestamp
        last_seen: timestamp
        samples: [Error]

    ErrorRecommendation:
        type: string
        description: string
        priority: int
        action: string
