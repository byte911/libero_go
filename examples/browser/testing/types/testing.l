-schema=testing_types
    version = 1.0

-types
    Test:
        id: string
        type: TestType
        name: string
        description?: string
        steps: [TestStep]
        assertions: [Assertion]

    TestType:
        enum:
            - UNIT
            - INTEGRATION
            - E2E
            - PERFORMANCE
            - SECURITY

    TestStep:
        id: string
        name: string
        action: TestAction
        data?: object
        timeout?: int

    TestAction:
        type: ActionType
        command: string
        params?: object

    ActionType:
        enum:
            - SETUP
            - EXECUTE
            - VERIFY
            - CLEANUP

    Assertion:
        id: string
        type: AssertionType
        target: string
        condition: string
        expected: any

    AssertionType:
        enum:
            - EQUALS
            - CONTAINS
            - MATCHES
            - GREATER
            - LESS

    TestSuite:
        id: string
        name: string
        tests: [Test]
        config: TestConfig
        metadata: TestMetadata

    TestConfig:
        environment: string
        timeout: int
        retries?: int
        parallel?: bool

    TestMetadata:
        author: string
        created: timestamp
        tags: [string]
        priority: int

    TestResult:
        id: string
        test_id: string
        status: TestStatus
        duration: int
        assertions: [AssertionResult]

    TestStatus:
        enum:
            - PASSED
            - FAILED
            - SKIPPED
            - ERROR

    AssertionResult:
        assertion_id: string
        passed: bool
        actual?: any
        message?: string

    TestRun:
        id: string
        suite_id: string
        timestamp: timestamp
        status: RunStatus
        results: [TestResult]

    RunStatus:
        enum:
            - RUNNING
            - COMPLETED
            - ABORTED
            - ERROR

    TestCoverage:
        total: int
        covered: int
        by_type: {string: float}
        by_component: {string: float}

    TestDependency:
        id: string
        type: DependencyType
        target: string
        config?: object

    DependencyType:
        enum:
            - DATABASE
            - SERVICE
            - MOCK
            - FIXTURE

    TestFixture:
        id: string
        type: string
        data: object
        cleanup?: string

    TestMock:
        id: string
        service: string
        responses: [MockResponse]

    MockResponse:
        request: object
        response: object
        delay?: int

    TestReport:
        id: string
        timestamp: timestamp
        duration: int
        summary: TestSummary
        results: [TestResult]
        coverage?: TestCoverage

    TestSummary:
        total: int
        passed: int
        failed: int
        skipped: int
        success_rate: float
