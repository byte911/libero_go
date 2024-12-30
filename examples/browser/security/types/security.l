-schema=security_types
    version = 1.0

-types
    SecurityContext:
        id: string
        type: ContextType
        subject: Subject
        resource: Resource
        environment: Environment

    ContextType:
        enum:
            - USER
            - SYSTEM
            - SERVICE
            - PROCESS

    Subject:
        id: string
        type: SubjectType
        attributes: [Attribute]
        credentials?: Credentials

    SubjectType:
        enum:
            - USER
            - GROUP
            - SERVICE
            - ROLE

    Resource:
        id: string
        type: ResourceType
        path: string
        attributes: [Attribute]

    ResourceType:
        enum:
            - FILE
            - API
            - DATABASE
            - SERVICE

    Environment:
        timestamp: timestamp
        location?: string
        device?: string
        network?: string

    Attribute:
        key: string
        value: any
        metadata?: object

    Credentials:
        type: CredentialType
        value: string
        expires?: timestamp
        metadata?: object

    CredentialType:
        enum:
            - PASSWORD
            - TOKEN
            - CERTIFICATE
            - KEY

    Permission:
        id: string
        action: string
        resource: string
        conditions?: [Condition]

    Condition:
        type: ConditionType
        value: any
        operator: string

    ConditionType:
        enum:
            - TIME
            - LOCATION
            - DEVICE
            - NETWORK

    Policy:
        id: string
        name: string
        effect: PolicyEffect
        subjects: [string]
        resources: [string]
        actions: [string]
        conditions?: [Condition]

    PolicyEffect:
        enum:
            - ALLOW
            - DENY

    SecurityEvent:
        id: string
        type: EventType
        context: SecurityContext
        timestamp: timestamp
        data: EventData

    EventType:
        enum:
            - ACCESS
            - AUTH
            - AUDIT
            - THREAT

    EventData:
        action: string
        outcome: string
        details?: object

    SecurityCheck:
        id: string
        type: CheckType
        target: string
        rules: [SecurityRule]

    CheckType:
        enum:
            - AUTH
            - ACCESS
            - INTEGRITY
            - THREAT

    SecurityRule:
        id: string
        type: RuleType
        pattern: string
        severity: Severity
        action: string

    RuleType:
        enum:
            - PATTERN
            - SIGNATURE
            - BEHAVIOR
            - ANOMALY

    Severity:
        enum:
            - CRITICAL
            - HIGH
            - MEDIUM
            - LOW

    SecurityMetrics:
        total_events: int
        by_type: {string: int}
        by_outcome: {string: int}
        by_severity: {string: int}

    SecurityReport:
        id: string
        timestamp: timestamp
        duration: int
        metrics: SecurityMetrics
        events: [SecurityEvent]
        threats: [ThreatInfo]

    ThreatInfo:
        type: string
        source: string
        target: string
        severity: Severity
        details: object
