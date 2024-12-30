-schema=event_types
    version = 1.0

-types
    Event:
        id: string
        type: EventType
        source: string
        timestamp: timestamp
        data: EventData
        metadata: EventMetadata

    EventType:
        enum:
            - SYSTEM
            - USER
            - SECURITY
            - RESOURCE
            - NETWORK
            - APPLICATION

    EventData:
        payload: any
        schema?: string
        version?: string
        encoding?: string

    EventMetadata:
        correlation_id?: string
        causation_id?: string
        user?: string
        session?: string
        tags: [string]

    EventHandler:
        id: string
        type: HandlerType
        filters: [EventFilter]
        action: EventAction
        config: HandlerConfig

    HandlerType:
        enum:
            - SYNC
            - ASYNC
            - BATCH
            - RETRY

    EventFilter:
        type: FilterType
        pattern: string
        config: FilterConfig

    FilterType:
        enum:
            - TYPE
            - SOURCE
            - DATA
            - METADATA

    FilterConfig:
        case_sensitive?: bool
        whole_word?: bool
        regex?: bool

    EventAction:
        type: ActionType
        target: string
        params: object

    ActionType:
        enum:
            - NOTIFY
            - TRANSFORM
            - AGGREGATE
            - FORWARD

    EventBatch:
        id: string
        events: [Event]
        metadata: BatchMetadata

    BatchMetadata:
        size: int
        created: timestamp
        expires?: timestamp

    EventSubscription:
        id: string
        subscriber: string
        filters: [EventFilter]
        config: SubscriptionConfig

    SubscriptionConfig:
        mode: DeliveryMode
        retry?: RetryConfig
        timeout?: int

    DeliveryMode:
        enum:
            - PUSH
            - PULL
            - STREAM

    RetryConfig:
        max_attempts: int
        interval: int
        backoff: float

    EventStream:
        id: string
        type: StreamType
        filters: [EventFilter]
        config: StreamConfig

    StreamType:
        enum:
            - REALTIME
            - REPLAY
            - FILTERED

    StreamConfig:
        buffer_size: int
        timeout?: int
        batch_size?: int

    EventPattern:
        id: string
        sequence: [EventFilter]
        window: int
        config: PatternConfig

    PatternConfig:
        strict: bool
        timeout?: int
        max_matches?: int

    EventMetrics:
        total: int
        by_type: {string: int}
        by_source: {string: int}
        latency: {
            avg: float,
            max: float,
            p95: float
        }

    EventReport:
        id: string
        timestamp: timestamp
        duration: int
        metrics: EventMetrics
        patterns: [PatternMatch]
        issues: [EventIssue]

    PatternMatch:
        pattern_id: string
        events: [string]
        duration: int
        score: float

    EventIssue:
        type: IssueType
        source: string
        message: string
        count: int

    IssueType:
        enum:
            - DELIVERY_FAILURE
            - PATTERN_TIMEOUT
            - HANDLER_ERROR
            - INVALID_DATA
