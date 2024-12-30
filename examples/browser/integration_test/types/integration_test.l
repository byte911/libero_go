-schema=integration_test_types
    version = 1.0

-types
    IntegrationTest:
        id: string
        name: string
        description?: string
        components: [Component]
        dependencies: [Dependency]
        scenarios: [IntegrationScenario]
        environment: TestEnvironment

    Component:
        name: string
        type: ComponentType
        version: string
        config: object
        health_check: HealthCheck

    ComponentType:
        enum:
            - NETWORK
            - STORAGE
            - RENDERER
            - JAVASCRIPT_ENGINE
            - SECURITY
            - EXTENSION
            - UI

    Dependency:
        source: string
        target: string
        type: DependencyType
        required: bool

    DependencyType:
        enum:
            - API
            - EVENT
            - DATA
            - RESOURCE

    IntegrationScenario:
        name: string
        description?: string
        steps: [IntegrationStep]
        assertions: [Assertion]
        cleanup?: CleanupAction

    IntegrationStep:
        id: string
        component: string
        action: Action
        dependencies?: [string]
        timeout?: int
        retry?: RetryPolicy

    Action:
        type: ActionType
        params: object
        expected_result?: ExpectedResult

    ActionType:
        enum:
            - INITIALIZE
            - CONFIGURE
            - START
            - STOP
            - SEND_EVENT
            - CALL_API
            - MODIFY_STATE

    ExpectedResult:
        type: ResultType
        value: any
        timeout?: int

    ResultType:
        enum:
            - STATE
            - EVENT
            - RESPONSE
            - ERROR

    Assertion:
        description: string
        condition: string
        severity: AssertionSeverity
        timeout?: int

    AssertionSeverity:
        enum:
            - CRITICAL
            - ERROR
            - WARNING
            - INFO

    RetryPolicy:
        attempts: int
        interval: int
        backoff?: float

    HealthCheck:
        endpoint?: string
        timeout: int
        interval: int
        threshold: int

    TestEnvironment:
        name: string
        type: EnvironmentType
        config: object
        resources: [Resource]

    EnvironmentType:
        enum:
            - LOCAL
            - STAGING
            - PRODUCTION
            - ISOLATED

    Resource:
        name: string
        type: ResourceType
        config: object

    ResourceType:
        enum:
            - CPU
            - MEMORY
            - STORAGE
            - NETWORK

    IntegrationResult:
        test_id: string
        status: TestStatus
        duration: int
        component_results: [ComponentResult]
        scenario_results: [ScenarioResult]
        issues: [IntegrationIssue]

    ComponentResult:
        component: string
        status: ComponentStatus
        metrics: object
        logs: [string]

    ComponentStatus:
        enum:
            - HEALTHY
            - DEGRADED
            - FAILED
            - UNKNOWN

    ScenarioResult:
        scenario: string
        status: TestStatus
        duration: int
        step_results: [StepResult]
        assertion_results: [AssertionResult]

    StepResult:
        step_id: string
        status: TestStatus
        duration: int
        output?: any
        error?: string

    AssertionResult:
        assertion: string
        status: TestStatus
        details?: string

    TestStatus:
        enum:
            - PASSED
            - FAILED
            - SKIPPED
            - ERROR

    IntegrationIssue:
        type: IssueType
        component?: string
        description: string
        severity: IssueSeverity
        trace?: string

    IssueType:
        enum:
            - CONFIGURATION
            - DEPENDENCY
            - PERFORMANCE
            - RESOURCE
            - TIMING

    IssueSeverity:
        enum:
            - CRITICAL
            - HIGH
            - MEDIUM
            - LOW
