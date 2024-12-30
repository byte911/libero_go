-schema=deployment_types
    version = 1.0

-types
    Deployment:
        id: string
        name: string
        version: string
        environment: string
        components: [Component]
        config: DeploymentConfig
        status: DeploymentStatus

    Component:
        id: string
        name: string
        type: ComponentType
        source: Source
        dependencies: [Dependency]
        config: ComponentConfig

    ComponentType:
        enum:
            - SERVICE
            - LIBRARY
            - DATABASE
            - FRONTEND
            - BACKEND

    Source:
        type: SourceType
        location: string
        version: string
        credentials?: object

    SourceType:
        enum:
            - GIT
            - REGISTRY
            - ARTIFACT
            - LOCAL

    Dependency:
        id: string
        type: DependencyType
        target: string
        version: string
        optional: bool

    DependencyType:
        enum:
            - RUNTIME
            - BUILD
            - TEST
            - DEPLOY

    DeploymentConfig:
        strategy: Strategy
        resources: ResourceRequirements
        scaling: ScalingConfig
        monitoring: MonitoringConfig

    Strategy:
        type: StrategyType
        config: object
        rollback?: RollbackConfig

    StrategyType:
        enum:
            - ROLLING
            - BLUE_GREEN
            - CANARY
            - RECREATE

    ResourceRequirements:
        cpu: string
        memory: string
        storage?: string
        network?: object

    ScalingConfig:
        min: int
        max: int
        target: object
        rules: [ScalingRule]

    ScalingRule:
        metric: string
        threshold: float
        operator: string
        action: string

    MonitoringConfig:
        metrics: [string]
        alerts: [AlertRule]
        logs: LogConfig

    AlertRule:
        metric: string
        condition: string
        severity: string
        action: string

    LogConfig:
        level: string
        format: string
        retention: string

    DeploymentStatus:
        phase: Phase
        conditions: [Condition]
        resources: ResourceStatus
        components: [ComponentStatus]

    Phase:
        enum:
            - PENDING
            - DEPLOYING
            - DEPLOYED
            - FAILED
            - ROLLING_BACK

    Condition:
        type: string
        status: string
        reason?: string
        message?: string

    ResourceStatus:
        allocated: object
        used: object
        available: object

    ComponentStatus:
        component_id: string
        phase: Phase
        health: HealthStatus
        message?: string

    HealthStatus:
        enum:
            - HEALTHY
            - DEGRADED
            - UNHEALTHY

    DeploymentReport:
        id: string
        timestamp: timestamp
        deployment_id: string
        duration: int
        status: DeploymentStatus
        metrics: DeploymentMetrics
        events: [DeploymentEvent]

    DeploymentMetrics:
        success_rate: float
        deployment_time: int
        rollback_count: int
        resource_usage: object

    DeploymentEvent:
        timestamp: timestamp
        type: string
        component?: string
        message: string
        data?: object
