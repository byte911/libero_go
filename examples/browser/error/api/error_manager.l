-schema=error_manager_api
    version = 1.0

-import
    error = "../types/error.l"

-api
    ErrorManager:
        HandleError:
            input: {
                error: error.Error,
                context?: object
            }
            output: {
                handled: bool,
                actions: [string],
                error?: string
            }

        RegisterHandler:
            input: {
                handler: error.ErrorHandler
            }
            output: {
                handler_id: string,
                error?: string
            }

        RegisterPolicy:
            input: {
                policy: error.ErrorPolicy
            }
            output: {
                policy_id: string,
                error?: string
            }

        ExecuteAction:
            input: {
                action: error.ErrorAction,
                context: object
            }
            output: {
                success: bool,
                result?: object,
                error?: string
            }

        GetErrorMetrics:
            input: {
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                group_by?: [string]
            }
            output: {
                metrics?: error.ErrorMetrics,
                error?: string
            }

        AnalyzeErrors:
            input: {
                errors: [error.Error],
                options?: {
                    group_by?: string,
                    threshold?: int
                }
            }
            output: {
                report?: error.ErrorReport,
                error?: string
            }

        GetRecommendations:
            input: {
                error_type: string,
                context?: object
            }
            output: {
                recommendations: [error.ErrorRecommendation],
                error?: string
            }

-rules
    ErrorHandling:
        when: error_received
        validate:
            - verify_error
            - check_context
            - validate_policies
        actions:
            - match_policies
            - execute_handlers
            - record_metrics

    PolicyManagement:
        when: policy_updated
        validate:
            - verify_patterns
            - check_handlers
            - validate_priority
        actions:
            - update_policies
            - notify_changes
            - sync_state

    MetricsCollection:
        when: metrics_requested
        validate:
            - verify_timerange
            - check_grouping
            - validate_access
        actions:
            - collect_metrics
            - calculate_trends
            - generate_report
