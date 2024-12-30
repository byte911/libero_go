-schema=metric_collector_api
    version = 1.0

-import
    monitoring = "../types/monitoring.l"

-api
    MetricCollector:
        CollectSystemMetrics:
            input: {
                options?: {
                    cpu?: bool,
                    memory?: bool,
                    disk?: bool,
                    network?: bool
                }
            }
            output: {
                metrics?: monitoring.SystemState,
                error?: string
            }

        CollectProcessMetrics:
            input: {
                pid: int,
                metrics: [string]
            }
            output: {
                info?: monitoring.ProcessInfo,
                error?: string
            }

        CollectNetworkMetrics:
            input: {
                interface?: string,
                protocols?: [string]
            }
            output: {
                state?: monitoring.NetworkState,
                error?: string
            }

        CollectIOMetrics:
            input: {
                device?: string,
                operations?: [string]
            }
            output: {
                stats?: monitoring.IOStats,
                error?: string
            }

        AggregateMetrics:
            input: {
                metrics: [monitoring.MetricValue],
                aggregation: monitoring.AggregationType
            }
            output: {
                result?: monitoring.Statistics,
                error?: string
            }

        StoreMetrics:
            input: {
                data: monitoring.MonitoringData,
                retention?: int
            }
            output: {
                success: bool,
                error?: string
            }

        QueryMetrics:
            input: {
                query: string,
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                aggregation?: monitoring.AggregationType
            }
            output: {
                data?: [monitoring.MetricValue],
                error?: string
            }

-rules
    MetricCollection:
        when: collection_started
        validate:
            - verify_permissions
            - check_availability
            - validate_metrics
        actions:
            - collect_data
            - process_metrics
            - store_results

    DataAggregation:
        when: aggregation_needed
        validate:
            - verify_data_types
            - check_timestamps
            - validate_operation
        actions:
            - group_metrics
            - apply_aggregation
            - format_results

    DataStorage:
        when: storage_requested
        validate:
            - verify_data_format
            - check_retention
            - validate_space
        actions:
            - prepare_storage
            - write_data
            - cleanup_old
