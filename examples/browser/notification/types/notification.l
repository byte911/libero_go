-schema=notification_types
    version = 1.0

-types
    Notification:
        id: string
        type: NotificationType
        priority: Priority
        content: NotificationContent
        metadata: NotificationMetadata
        delivery: DeliveryInfo

    NotificationType:
        enum:
            - ALERT
            - INFO
            - UPDATE
            - WARNING
            - ACTION

    Priority:
        enum:
            - CRITICAL
            - HIGH
            - MEDIUM
            - LOW

    NotificationContent:
        title: string
        message: string
        data?: object
        template?: string

    NotificationMetadata:
        created: timestamp
        expires?: timestamp
        source: string
        tags: [string]

    DeliveryInfo:
        channels: [Channel]
        schedule?: Schedule
        attempts: int
        status: DeliveryStatus

    Channel:
        type: ChannelType
        config: ChannelConfig
        status: ChannelStatus

    ChannelType:
        enum:
            - EMAIL
            - PUSH
            - SMS
            - WEBHOOK
            - IN_APP

    ChannelConfig:
        provider: string
        credentials?: object
        template?: string
        retry?: RetryConfig

    ChannelStatus:
        active: bool
        last_success?: timestamp
        last_failure?: timestamp
        error_count: int

    Schedule:
        start?: timestamp
        end?: timestamp
        frequency?: string
        timezone?: string

    DeliveryStatus:
        enum:
            - PENDING
            - DELIVERED
            - FAILED
            - EXPIRED

    RetryConfig:
        max_attempts: int
        interval: int
        backoff: float

    NotificationTemplate:
        id: string
        type: NotificationType
        content: TemplateContent
        variables: [TemplateVariable]

    TemplateContent:
        title: string
        message: string
        format: string

    TemplateVariable:
        name: string
        type: string
        default?: string
        required: bool

    Recipient:
        id: string
        type: RecipientType
        channels: [RecipientChannel]
        preferences: RecipientPreferences

    RecipientType:
        enum:
            - USER
            - GROUP
            - SYSTEM

    RecipientChannel:
        type: ChannelType
        value: string
        verified: bool

    RecipientPreferences:
        channels: [ChannelType]
        schedule?: Schedule
        filters: [NotificationFilter]

    NotificationFilter:
        type: FilterType
        value: string
        enabled: bool

    FilterType:
        enum:
            - TYPE
            - PRIORITY
            - SOURCE
            - TAG

    NotificationMetrics:
        total: int
        by_type: {string: int}
        by_priority: {string: int}
        by_status: {string: int}
        by_channel: {string: int}

    NotificationReport:
        id: string
        timestamp: timestamp
        duration: int
        metrics: NotificationMetrics
        failures: [DeliveryFailure]
        insights: [NotificationInsight]

    DeliveryFailure:
        notification_id: string
        channel: ChannelType
        error: string
        timestamp: timestamp

    NotificationInsight:
        type: string
        metric: string
        value: float
        trend: string
