-schema=profiling_types
    version = 1.0

-types
    Profile:
        id: string
        name: string
        description?: string
        type: ProfileType
        target: ProfileTarget
        config: ProfileConfig

    ProfileType:
        enum:
            - CPU
            - MEMORY
            - HEAP
            - NETWORK
            - RENDERING
            - JAVASCRIPT

    ProfileTarget:
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

    ProfileConfig:
        sampling: SamplingConfig
        filters?: FilterConfig
        events?: [string]

    SamplingConfig:
        interval: int
        duration: int
        resolution?: int

    FilterConfig:
        include?: [string]
        exclude?: [string]
        threshold?: float

    ProfileData:
        profile_id: string
        timestamp: timestamp
        duration: int
        samples: [Sample]
        events: [ProfileEvent]
        statistics: Statistics

    Sample:
        timestamp: timestamp
        stack: [StackFrame]
        metrics: {string: float}

    StackFrame:
        function: string
        file: string
        line: int
        column: int
        module?: string

    ProfileEvent:
        timestamp: timestamp
        type: string
        data: object

    Statistics:
        samples: int
        duration: int
        metrics: {string: MetricStats}

    MetricStats:
        min: float
        max: float
        avg: float
        total: float
        percentiles: {string: float}

    HeapSnapshot:
        timestamp: timestamp
        nodes: [HeapNode]
        edges: [HeapEdge]
        statistics: HeapStats

    HeapNode:
        id: int
        type: string
        name: string
        size: int
        references: [int]

    HeapEdge:
        from: int
        to: int
        type: string

    HeapStats:
        total_size: int
        total_objects: int
        garbage_size: int

    TimelineTrace:
        timestamp: timestamp
        duration: int
        events: [TraceEvent]
        frames: [TraceFrame]

    TraceEvent:
        timestamp: timestamp
        type: string
        category: string
        data: object

    TraceFrame:
        timestamp: timestamp
        duration: int
        events: [string]
        metrics: object

    ProfilingReport:
        id: string
        timestamp: timestamp
        duration: int
        profiles: [ProfileSummary]
        recommendations: [Recommendation]

    ProfileSummary:
        profile_id: string
        type: ProfileType
        metrics: {string: float}
        hotspots: [Hotspot]

    Hotspot:
        location: string
        metric: string
        value: float
        impact: float

    Recommendation:
        type: string
        description: string
        impact: string
        action: string
        priority: Priority

    Priority:
        enum:
            - CRITICAL
            - HIGH
            - MEDIUM
            - LOW
