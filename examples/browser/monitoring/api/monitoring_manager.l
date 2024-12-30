-schema=monitoring_manager_api
    version = 1.0

-import
    monitoring = "../types/monitoring.l"

-api
    MonitoringManager:
        StartMonitoring:
            input: {
                monitor: monitoring.Monitor,
                options?: {
                    interval?: int,
                    retention?: int
                }
            }
            output: {
                monitor_id: string,
                error?: string
            }

        StopMonitoring:
            input: {
                monitor_id: string
            }
            output: {
                success: bool,
                error?: string
            }

        CollectMetrics:
            input: {
                target: monitoring.MonitorTarget,
                metrics: [string]
            }
            output: {
                data?: monitoring.MonitoringData,
                error?: string
            }

        GetSystemState:
            input: {
                components: [string]
            }
            output: {
                state?: monitoring.SystemState,
                error?: string
            }

        CheckAlerts:
            input: {
                rules: [monitoring.AlertRule],
                data: monitoring.MonitoringData
            }
            output: {
                alerts: [monitoring.AlertSummary],
                error?: string
            }

        ExecuteAction:
            input: {
                action: monitoring.AlertAction,
                context: object
            }
            output: {
                success: bool,
                error?: string
            }

        GenerateReport:
            input: {
                data: [monitoring.MonitoringData],
                options?: {
                    format?: string,
                    interval?: string,
                    metrics?: [string]
                }
            }
            output: {
                report?: monitoring.MonitoringReport,
                error?: string
            }

-rules
    MonitoringExecution:
        when: monitoring_started
        validate:
            - verify_monitor_config
            - check_permissions
            - validate_targets
        actions:
            - setup_collectors
            - start_sampling
            - check_alerts

    MetricCollection:
        when: metric_collection
        validate:
            - verify_metric_types
            - check_sampling
            - validate_values
        actions:
            - collect_metrics
            - aggregate_data
            - store_results

    AlertProcessing:
        when: alert_check
        validate:
            - verify_conditions
            - check_thresholds
            - validate_actions
        actions:
            - evaluate_rules
            - trigger_alerts
            - execute_actions
