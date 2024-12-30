-schema=resource_types
    version = 1.0

-types
    Resource:
        id: string
        type: ResourceType
        state: ResourceState
        metadata: ResourceMetadata
        config: ResourceConfig

    ResourceType:
        enum:
            - MEMORY
            - CPU
            - STORAGE
            - NETWORK
            - THREAD
            - FILE
            - DATABASE

    ResourceState:
        status: ResourceStatus
        usage: ResourceUsage
        limits: ResourceLimits
        metrics: ResourceMetrics

    ResourceStatus:
        enum:
            - AVAILABLE
            - BUSY
            - EXHAUSTED
            - ERROR

    ResourceUsage:
        current: float
        peak: float
        average: float
        history: [UsagePoint]

    UsagePoint:
        timestamp: timestamp
        value: float

    ResourceLimits:
        soft: float
        hard: float
        threshold: float

    ResourceMetrics:
        utilization: float
        saturation: float
        errors: int
        latency: float

    ResourceMetadata:
        name: string
        description?: string
        owner?: string
        tags: [string]
        created: timestamp

    ResourceConfig:
        priority: int
        quota: float
        policy: AllocationPolicy
        constraints: [ResourceConstraint]

    AllocationPolicy:
        type: PolicyType
        params: object

    PolicyType:
        enum:
            - FIFO
            - PRIORITY
            - FAIR
            - WEIGHTED

    ResourceConstraint:
        type: ConstraintType
        value: any
        priority: int

    ConstraintType:
        enum:
            - MIN_VALUE
            - MAX_VALUE
            - RATE_LIMIT
            - TIME_WINDOW

    ResourcePool:
        id: string
        resources: [Resource]
        policy: AllocationPolicy
        metrics: PoolMetrics

    PoolMetrics:
        total: float
        available: float
        allocated: float
        waiting: int

    ResourceRequest:
        id: string
        type: ResourceType
        amount: float
        priority: int
        constraints: [ResourceConstraint]

    ResourceAllocation:
        id: string
        request_id: string
        resource_id: string
        amount: float
        timestamp: timestamp
        expiry?: timestamp

    ResourceEvent:
        type: EventType
        resource_id: string
        data: object
        timestamp: timestamp

    EventType:
        enum:
            - ALLOCATED
            - RELEASED
            - EXHAUSTED
            - RECOVERED

    ResourceReport:
        id: string
        timestamp: timestamp
        duration: int
        pools: [PoolStatus]
        events: [ResourceEvent]
        metrics: ResourceMetrics

    PoolStatus:
        pool_id: string
        resources: int
        utilization: float
        waiting: int
        rejected: int
