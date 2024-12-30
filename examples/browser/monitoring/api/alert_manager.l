-schema=alert_manager_api
    version = 1.0

-import
    monitoring = "../types/monitoring.l"

-api
    AlertManager:
        CreateAlert:
            input: {
                alert: monitoring.Alert
            }
            output: {
                alert_id: string,
                error?: string
            }

        ProcessAlert:
            input: {
                alert_id: string,
                action: string
            }
            output: {
                success: bool,
                error?: string
            }

        UpdateAlertStatus:
            input: {
                alert_id: string,
                status: monitoring.AlertStatus
            }
            output: {
                success: bool,
                error?: string
            }

        GetAlertHistory:
            input: {
                alert_id: string,
                timerange: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                history: [monitoring.AlertEvent],
                error?: string
            }

        SetAlertPolicy:
            input: {
                policy: monitoring.AlertPolicy
            }
            output: {
                policy_id: string,
                error?: string
            }

        EvaluateAlerts:
            input: {
                alerts: [monitoring.Alert],
                policies: [monitoring.AlertPolicy]
            }
            output: {
                actions: [object],
                error?: string
            }

        AggregateAlerts:
            input: {
                alerts: [monitoring.Alert],
                group_by: [string]
            }
            output: {
                groups: [object],
                error?: string
            }

        GenerateReport:
            input: {
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                options?: {
                    include_history?: bool,
                    include_metrics?: bool
                }
            }
            output: {
                report?: monitoring.AlertReport,
                error?: string
            }

-rules
    AlertProcessing:
        when: alert_received
        validate:
            - verify_alert
            - check_policies
            - validate_actions
        actions:
            - process_alert
            - execute_actions
            - update_status

    PolicyEvaluation:
        when: policy_check
        validate:
            - verify_policies
            - check_conditions
            - validate_alerts
        actions:
            - evaluate_policies
            - determine_actions
            - execute_actions

    AlertAggregation:
        when: aggregation_requested
        validate:
            - verify_alerts
            - check_grouping
            - validate_criteria
        actions:
            - group_alerts
            - analyze_groups
            - generate_summary
