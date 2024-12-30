-schema=deployment_orchestrator_api
    version = 1.0

-import
    deployment = "../types/deployment.l"

-api
    DeploymentOrchestrator:
        PlanDeployment:
            input: {
                deployment: deployment.Deployment,
                constraints?: object
            }
            output: {
                plan: object,
                error?: string
            }

        ExecutePlan:
            input: {
                plan: object,
                options?: object
            }
            output: {
                status?: deployment.DeploymentStatus,
                error?: string
            }

        OptimizeResources:
            input: {
                deployment_id: string,
                target: string
            }
            output: {
                recommendations: [object],
                error?: string
            }

        ManageDependencies:
            input: {
                deployment_id: string,
                action: string
            }
            output: {
                success: bool,
                error?: string
            }

        CoordinateRollout:
            input: {
                deployment_id: string,
                strategy: deployment.Strategy
            }
            output: {
                status?: deployment.DeploymentStatus,
                error?: string
            }

        MonitorHealth:
            input: {
                deployment_id: string,
                checks: [string]
            }
            output: {
                health: [deployment.HealthStatus],
                error?: string
            }

-rules
    PlanningExecution:
        when: planning_started
        validate:
            - verify_deployment
            - check_constraints
            - validate_resources
        actions:
            - analyze_dependencies
            - create_plan
            - validate_plan

    ResourceOptimization:
        when: optimization_requested
        validate:
            - verify_deployment
            - check_target
            - validate_metrics
        actions:
            - analyze_usage
            - generate_options
            - rank_recommendations

    HealthMonitoring:
        when: health_check
        validate:
            - verify_components
            - check_health
            - validate_metrics
        actions:
            - monitor_health
            - detect_issues
            - update_status
