-schema=monitor_manager_api
    version = 1.0

-import
    monitoring = "../types/monitoring.l"

-api
    MonitorManager:
        CreateMonitor:
            input: {
                monitor: monitoring.Monitor
            }
            output: {
                monitor_id: string,
                error?: string
            }

        StartMonitoring:
            input: {
                monitor_id: string,
                config?: monitoring.MonitorConfig
            }
            output: {
                success: bool,
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

        GetMetrics:
            input: {
                monitor_id: string,
                metrics: [string],
                timerange: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                metrics?: monitoring.MetricData,
                error?: string
            }

        SetAlertRule:
            input: {
                monitor_id: string,
                rule: monitoring.AlertRule
            }
            output: {
                rule_id: string,
                error?: string
            }

        CheckAlerts:
            input: {
                monitor_id: string,
                timerange?: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                alerts: [monitoring.Alert],
                error?: string
            }

        CollectLogs:
            input: {
                monitor_id: string,
                filter?: monitoring.LogFilter,
                timerange: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                logs: [monitoring.Log],
                error?: string
            }

        GenerateReport:
            input: {
                monitor_id: string,
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                options?: {
                    include_metrics?: bool,
                    include_alerts?: bool,
                    include_logs?: bool
                }
            }
            output: {
                report?: monitoring.MonitorReport,
                error?: string
            }

-rules
    MonitoringExecution:
        when: monitoring_started
        validate:
            - verify_monitor
            - check_config
            - validate_metrics
        actions:
            - start_collection
            - process_data
            - store_metrics

    AlertProcessing:
        when: alert_check
        validate:
            - verify_rules
            - check_thresholds
            - validate_conditions
        actions:
            - evaluate_rules
            - generate_alerts
            - notify_handlers

    LogCollection:
        when: log_collection
        validate:
            - verify_filter
            - check_timerange
            - validate_sources
        actions:
            - collect_logs
            - process_logs
            - store_logs
