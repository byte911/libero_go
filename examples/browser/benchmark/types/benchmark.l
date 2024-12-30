-schema=benchmark_types
    version = 1.0

-types
    Benchmark:
        id: string
        name: string
        description?: string
        category: BenchmarkCategory
        metrics: [MetricDefinition]
        scenarios: [Scenario]
        baseline?: BaselineMetrics

    BenchmarkCategory:
        enum:
            - RENDERING
            - NETWORKING
            - JAVASCRIPT
            - MEMORY
            - STORAGE
            - STARTUP
            - INTERACTION

    MetricDefinition:
        name: string
        unit: string
        direction: MetricDirection  # higher or lower is better
        threshold?: {
            warning: float,
            error: float
        }

    MetricDirection:
        enum:
            - HIGHER_BETTER
            - LOWER_BETTER

    Scenario:
        name: string
        steps: [BenchmarkStep]
        load: LoadProfile
        environment: EnvironmentSpec

    BenchmarkStep:
        type: StepType
        params: object
        duration?: int
        wait_until?: WaitCondition

    StepType:
        enum:
            - LOAD_PAGE
            - SCROLL
            - CLICK
            - TYPE
            - WAIT
            - EXECUTE_JS
            - NETWORK_REQUEST

    LoadProfile:
        type: LoadType
        users: int
        ramp_up?: int
        duration: int
        think_time?: int

    LoadType:
        enum:
            - CONSTANT
            - RAMP_UP
            - SPIKE
            - RANDOM

    EnvironmentSpec:
        cpu: CPUSpec
        memory: MemorySpec
        network: NetworkSpec
        viewport: ViewportSpec

    CPUSpec:
        throttling?: float
        cores?: int

    MemorySpec:
        limit?: int
        pressure?: float

    NetworkSpec:
        type: NetworkType
        latency?: int
        bandwidth?: int
        loss?: float

    NetworkType:
        enum:
            - WIFI
            - 4G
            - 3G
            - 2G
            - OFFLINE

    ViewportSpec:
        width: int
        height: int
        device_scale_factor: float

    WaitCondition:
        type: WaitType
        timeout: int

    WaitType:
        enum:
            - NETWORK_IDLE
            - DOM_READY
            - LOAD
            - ANIMATION_END
            - CUSTOM

    BaselineMetrics:
        timestamp: timestamp
        environment: EnvironmentSpec
        metrics: {string: float}  # metric name -> value

    BenchmarkResult:
        benchmark_id: string
        timestamp: timestamp
        duration: int
        metrics: [MetricResult]
        traces: [PerformanceTrace]
        errors: [BenchmarkError]

    MetricResult:
        name: string
        value: float
        unit: string
        samples: [float]
        statistics: Statistics
        comparison?: BaselineComparison

    Statistics:
        mean: float
        median: float
        std_dev: float
        percentiles: {string: float}
        min: float
        max: float

    BaselineComparison:
        diff: float
        diff_pct: float
        regression: bool

    PerformanceTrace:
        name: string
        events: [TraceEvent]
        metrics: {string: float}

    TraceEvent:
        timestamp: timestamp
        category: string
        name: string
        duration: int
        args: object

    BenchmarkError:
        step: string
        type: string
        message: string
        timestamp: timestamp
