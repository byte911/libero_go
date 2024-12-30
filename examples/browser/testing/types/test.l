-schema=test_types
    version = 1.0

-types
    TestSuite:
        id: string
        name: string
        description?: string
        tests: [Test]
        hooks: TestHooks
        fixtures: [TestFixture]
        tags: [string]
        timeout?: int

    Test:
        id: string
        name: string
        description?: string
        type: TestType
        steps: [TestStep]
        expectations: [Expectation]
        timeout?: int
        retries?: int
        tags: [string]

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
        timeout?: int
        retry?: {
            count: int,
            interval: int
        }

    TestAction:
        type: ActionType
        params: object
        validation?: Validation

    ActionType:
        enum:
            - NAVIGATE
            - CLICK
            - TYPE
            - WAIT
            - ASSERT
            - EXECUTE
            - SCREENSHOT
            - NETWORK

    Validation:
        type: ValidationType
        value: any
        timeout?: int

    ValidationType:
        enum:
            - EQUALS
            - CONTAINS
            - MATCHES
            - EXISTS
            - VISIBLE
            - ENABLED

    Expectation:
        description: string
        condition: string
        timeout?: int

    TestHooks:
        before_all?: TestAction[]
        after_all?: TestAction[]
        before_each?: TestAction[]
        after_each?: TestAction[]

    TestFixture:
        name: string
        type: FixtureType
        data: any
        cleanup?: TestAction[]

    FixtureType:
        enum:
            - DATA
            - NETWORK
            - DOM
            - STATE

    TestResult:
        test_id: string
        status: TestStatus
        duration: int
        error?: TestError
        screenshots: [string]
        logs: [string]
        coverage?: Coverage

    TestStatus:
        enum:
            - PASSED
            - FAILED
            - SKIPPED
            - TIMEOUT
            - ERROR

    TestError:
        message: string
        stack?: string
        type: string
        screenshot?: string

    Coverage:
        statements: CoverageStats
        branches: CoverageStats
        functions: CoverageStats
        lines: CoverageStats

    CoverageStats:
        total: int
        covered: int
        skipped: int
        pct: float
