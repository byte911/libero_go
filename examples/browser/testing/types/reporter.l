-schema=reporter_types
    version = 1.0

-import
    test = "./test.l"

-types
    TestReport:
        id: string
        timestamp: timestamp
        duration: int
        summary: TestSummary
        results: [test.TestResult]
        coverage?: test.Coverage
        environment: TestEnvironment

    TestSummary:
        total: int
        passed: int
        failed: int
        skipped: int
        duration: int
        success_rate: float

    TestEnvironment:
        platform: string
        browser_version: string
        viewport: {
            width: int,
            height: int
        }
        device?: string
        network?: NetworkCondition

    NetworkCondition:
        latency: int
        download_throughput: int
        upload_throughput: int
        offline: bool

    ReportFormat:
        enum:
            - JSON
            - HTML
            - XML
            - JUNIT
            - TAP

    Metric:
        name: string
        value: float
        unit: string
        threshold?: float

    PerformanceReport:
        metrics: [Metric]
        traces: [PerformanceTrace]
        screenshots: [Screenshot]

    PerformanceTrace:
        name: string
        duration: int
        events: [TraceEvent]

    TraceEvent:
        timestamp: timestamp
        duration: int
        category: string
        name: string
        args: object

    Screenshot:
        timestamp: timestamp
        path: string
        tags: [string]
        viewport: {
            width: int,
            height: int
        }
