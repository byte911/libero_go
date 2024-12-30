-schema=monitoring_types
    version = 1.0

-types
    Monitor:
        id: string
        name: string
        description?: string
        type: MonitorType
        targets: [MonitorTarget]
        metrics: [MetricDefinition]
        alerts: [AlertRule]

    MonitorType:
        enum:
            - SYSTEM
            - PROCESS
            - NETWORK
            - MEMORY
            - DISK
            - EVENT

    MonitorTarget:
        name: string
        type: TargetType
        config: object
        filters?: [string]

    TargetType:
        enum:
            - BROWSER
            - TAB
            - EXTENSION
            - RENDERER
            - NETWORK_STACK
            - STORAGE

    MetricDefinition:
        name: string
        type: MetricType
        unit: string
        aggregation: AggregationType
        sampling: SamplingConfig

    MetricType:
        enum:
            - COUNTER
            - GAUGE
            - HISTOGRAM
            - SUMMARY

    AggregationType:
        enum:
            - SUM
            - AVG
            - MIN
            - MAX
            - COUNT
            - PERCENTILE

    SamplingConfig:
        interval: int
        retention: int
        resolution?: int

    AlertRule:
        name: string
        condition: string
        severity: AlertSeverity
        threshold: ThresholdConfig
        actions: [AlertAction]

    AlertSeverity:
        enum:
            - CRITICAL
            - HIGH
            - MEDIUM
            - LOW

    ThresholdConfig:
        operator: string
        value: float
        duration: int

    AlertAction:
        type: ActionType
        config: object

    ActionType:
        enum:
            - EMAIL
            - WEBHOOK
            - LOG
            - NOTIFICATION

    MonitoringData:
        timestamp: timestamp
        target: string
        metrics: {string: MetricValue}
        events: [MonitoringEvent]

    MetricValue:
        value: float
        labels: object
        metadata?: object

    MonitoringEvent:
        timestamp: timestamp
        type: string
        source: string
        data: object

    SystemState:
        timestamp: timestamp
        cpu: CPUState
        memory: MemoryState
        disk: DiskState
        network: NetworkState

    CPUState:
        usage: float
        temperature?: float
        processes: [ProcessInfo]

    MemoryState:
        total: int
        used: int
        free: int
        cached: int
        buffers: int

    DiskState:
        total: int
        used: int
        free: int
        io_stats: IOStats

    NetworkState:
        interfaces: [NetworkInterface]
        connections: [NetworkConnection]

    ProcessInfo:
        pid: int
        name: string
        cpu_usage: float
        memory_usage: int
        threads: int

    IOStats:
        reads: int
        writes: int
        read_bytes: int
        write_bytes: int

    NetworkInterface:
        name: string
        bytes_sent: int
        bytes_received: int
        packets_sent: int
        packets_received: int

    NetworkConnection:
        local_address: string
        remote_address: string
        state: string
        protocol: string

    MonitoringReport:
        id: string
        timestamp: timestamp
        duration: int
        targets: [string]
        metrics: [MetricSummary]
        alerts: [AlertSummary]

    MetricSummary:
        metric: string
        values: [MetricValue]
        statistics: Statistics

    Statistics:
        min: float
        max: float
        avg: float
        median: float
        percentiles: {string: float}

    AlertSummary:
        rule: string
        triggered: int
        active: int
        resolved: int
        duration: int
