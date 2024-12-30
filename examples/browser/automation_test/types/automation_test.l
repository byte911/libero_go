-schema=automation_test_types
    version = 1.0

-types
    AutomationTest:
        id: string
        name: string
        description?: string
        type: TestType
        priority: Priority
        suite: TestSuite
        dependencies?: [Dependency]

    TestType:
        enum:
            - E2E
            - FUNCTIONAL
            - REGRESSION
            - SMOKE
            - SANITY

    Priority:
        enum:
            - P0
            - P1
            - P2
            - P3

    TestSuite:
        setup?: [TestStep]
        steps: [TestStep]
        teardown?: [TestStep]
        data?: TestData
        assertions: [Assertion]

    TestStep:
        id: string
        action: Action
        target?: Element
        value?: any
        timeout?: int
        retry?: RetryPolicy
        screenshot?: bool

    Action:
        enum:
            - NAVIGATE
            - CLICK
            - TYPE
            - SELECT
            - WAIT
            - ASSERT
            - EXECUTE
            - SCROLL
            - HOVER
            - DRAG

    Element:
        selector: string
        type: SelectorType
        index?: int
        frame?: string

    SelectorType:
        enum:
            - CSS
            - XPATH
            - ID
            - NAME
            - CLASS
            - TAG

    TestData:
        inputs: object
        expected: object
        environment?: object

    Assertion:
        type: AssertionType
        target?: Element
        condition: string
        value?: any
        timeout?: int

    AssertionType:
        enum:
            - EQUALS
            - CONTAINS
            - EXISTS
            - VISIBLE
            - ENABLED
            - SELECTED

    RetryPolicy:
        attempts: int
        interval: int
        conditions?: [string]

    Dependency:
        type: DependencyType
        value: string

    DependencyType:
        enum:
            - TEST
            - SUITE
            - DATA
            - CONFIG

    AutomationResult:
        test_id: string
        status: TestStatus
        duration: int
        steps: [StepResult]
        assertions: [AssertionResult]
        screenshots: [Screenshot]
        logs: [LogEntry]

    TestStatus:
        enum:
            - PASSED
            - FAILED
            - SKIPPED
            - ERROR
            - BLOCKED

    StepResult:
        step_id: string
        status: TestStatus
        duration: int
        error?: string
        screenshot?: string

    AssertionResult:
        assertion: string
        status: TestStatus
        actual?: any
        expected?: any
        error?: string

    Screenshot:
        timestamp: timestamp
        path: string
        context: string
        metadata?: object

    LogEntry:
        timestamp: timestamp
        level: LogLevel
        message: string
        context?: object

    LogLevel:
        enum:
            - DEBUG
            - INFO
            - WARN
            - ERROR

    AutomationReport:
        id: string
        timestamp: timestamp
        duration: int
        summary: TestSummary
        results: [AutomationResult]
        environment: Environment

    TestSummary:
        total: int
        passed: int
        failed: int
        skipped: int
        blocked: int
        duration: int

    Environment:
        browser: string
        version: string
        platform: string
        viewport: {
            width: int,
            height: int
        }
        capabilities: object
