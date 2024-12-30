-schema=security_test_types
    version = 1.0

-types
    SecurityTest:
        id: string
        name: string
        description?: string
        category: SecurityCategory
        severity: SeverityLevel
        tests: [VulnerabilityTest]

    SecurityCategory:
        enum:
            - XSS
            - CSRF
            - INJECTION
            - AUTHENTICATION
            - AUTHORIZATION
            - CONFIGURATION
            - ENCRYPTION
            - PROTOCOL

    SeverityLevel:
        enum:
            - CRITICAL
            - HIGH
            - MEDIUM
            - LOW
            - INFO

    VulnerabilityTest:
        name: string
        type: TestType
        payload: Payload
        validation: ValidationRule
        cleanup?: CleanupAction

    TestType:
        enum:
            - ACTIVE_SCAN
            - PASSIVE_SCAN
            - FUZZING
            - CONFIGURATION_CHECK
            - DEPENDENCY_CHECK

    Payload:
        type: PayloadType
        content: string
        encoding?: string
        context?: string

    PayloadType:
        enum:
            - XSS_VECTOR
            - SQL_INJECTION
            - COMMAND_INJECTION
            - PATH_TRAVERSAL
            - TEMPLATE_INJECTION

    ValidationRule:
        type: ValidationType
        condition: string
        timeout?: int

    ValidationType:
        enum:
            - RESPONSE_CONTENT
            - RESPONSE_HEADER
            - DOM_STATE
            - NETWORK_TRAFFIC
            - SYSTEM_STATE

    CleanupAction:
        type: CleanupType
        steps: [string]

    CleanupType:
        enum:
            - REVERT_CHANGES
            - DELETE_DATA
            - RESET_STATE
            - RESTORE_BACKUP

    SecurityVulnerability:
        id: string
        test_id: string
        type: SecurityCategory
        severity: SeverityLevel
        description: string
        evidence: VulnerabilityEvidence
        remediation?: string

    VulnerabilityEvidence:
        request?: HttpRequest
        response?: HttpResponse
        payload?: string
        screenshot?: string
        logs: [string]

    HttpRequest:
        method: string
        url: string
        headers: {string: string}
        body?: string

    HttpResponse:
        status: int
        headers: {string: string}
        body?: string

    SecurityReport:
        id: string
        timestamp: timestamp
        duration: int
        summary: SecuritySummary
        vulnerabilities: [SecurityVulnerability]
        recommendations: [SecurityRecommendation]

    SecuritySummary:
        total_tests: int
        passed: int
        failed: int
        vulnerabilities: {
            critical: int,
            high: int,
            medium: int,
            low: int,
            info: int
        }

    SecurityRecommendation:
        category: SecurityCategory
        severity: SeverityLevel
        description: string
        impact: string
        mitigation: string
        references: [string]
