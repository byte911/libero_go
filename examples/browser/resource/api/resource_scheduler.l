-schema=resource_scheduler_api
    version = 1.0

-import
    resource = "../types/resource.l"

-api
    ResourceScheduler:
        ScheduleAllocation:
            input: {
                request: resource.ResourceRequest,
                constraints: [resource.ResourceConstraint]
            }
            output: {
                schedule?: resource.ResourceAllocation,
                error?: string
            }

        OptimizeAllocation:
            input: {
                pool_id: string,
                target: string,
                constraints?: [resource.ResourceConstraint]
            }
            output: {
                recommendations: [object],
                error?: string
            }

        PredictUsage:
            input: {
                resource_id: string,
                window: string,
                metrics: [string]
            }
            output: {
                predictions: [resource.UsagePoint],
                error?: string
            }

        BalanceLoad:
            input: {
                pool_id: string,
                threshold: float
            }
            output: {
                actions: [object],
                error?: string
            }

        DetectContention:
            input: {
                pool_id: string,
                metrics: [string]
            }
            output: {
                contentions: [object],
                error?: string
            }

        SuggestScaling:
            input: {
                pool_id: string,
                target_metrics: object
            }
            output: {
                suggestions: [object],
                error?: string
            }

-rules
    SchedulingExecution:
        when: scheduling_requested
        validate:
            - verify_request
            - check_constraints
            - validate_resources
        actions:
            - calculate_schedule
            - optimize_allocation
            - update_state

    OptimizationExecution:
        when: optimization_requested
        validate:
            - verify_target
            - check_metrics
            - validate_constraints
        actions:
            - analyze_usage
            - generate_options
            - rank_recommendations

    PredictionExecution:
        when: prediction_requested
        validate:
            - verify_history
            - check_window
            - validate_metrics
        actions:
            - analyze_trends
            - build_model
            - generate_predictions
