-schema=performance_types
    version = 1.0

-types
    Performance:
        id: string
        type: MetricType
        value: float
        timestamp: timestamp
        context: MetricContext
        metadata: MetricMetadata

    MetricType:
        enum:
            - LATENCY
            - THROUGHPUT
            - UTILIZATION
            - ERROR_RATE
            - AVAILABILITY

    MetricContext:
        component: string
        operation: string
        environment: string
        tags: [string]

    MetricMetadata:
        unit: string
        interval: int
        aggregation: string
        source: string

    Benchmark:
        id: string
        name: string
        metrics: [MetricDefinition]
        thresholds: [Threshold]
        config: BenchmarkConfig

    MetricDefinition:
        name: string
        type: MetricType
        description?: string
        unit: string

    Threshold:
        metric: string
        operator: string
        value: float
        severity: ThresholdSeverity

    ThresholdSeverity:
        enum:
            - CRITICAL
            - WARNING
            - INFO

    BenchmarkConfig:
        duration: int
        load: LoadProfile
        environment: string
        params?: object

    LoadProfile:
        type: LoadType
        params: LoadParams
        schedule?: LoadSchedule

    LoadType:
        enum:
            - CONSTANT
            - RAMP
            - SPIKE
            - RANDOM

    LoadParams:
        rate: float
        duration: int
        steps?: [LoadStep]

    LoadStep:
        rate: float
        duration: int

    LoadSchedule:
        start?: timestamp
        end?: timestamp
        repeat?: int

    Profile:
        id: string
        type: ProfileType
        data: ProfileData
        metadata: ProfileMetadata

    ProfileType:
        enum:
            - CPU
            - MEMORY
            - IO
            - NETWORK

    ProfileData:
        samples: [Sample]
        summary: ProfileSummary
        analysis: [ProfileInsight]

    Sample:
        timestamp: timestamp
        value: float
        stack?: [string]

    ProfileSummary:
        total: float
        mean: float
        max: float
        p95: float
        p99: float

    ProfileInsight:
        type: string
        metric: string
        value: float
        description: string

    Trace:
        id: string
        name: string
        timestamp: timestamp
        duration: int
        spans: [Span]

    Span:
        id: string
        parent_id?: string
        name: string
        start: timestamp
        duration: int
        tags: [string]

    PerformanceReport:
        id: string
        timestamp: timestamp
        duration: int
        metrics: [Performance]
        profiles: [Profile]
        traces: [Trace]
        insights: [PerformanceInsight]

    PerformanceInsight:
        type: string
        component: string
        metric: string
        value: float
        trend: string
        recommendation?: string
