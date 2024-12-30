-schema=metric_collector_api
    version = 1.0

-import
    benchmark = "../types/benchmark.l"

-api
    MetricCollector:
        CollectRenderingMetrics:
            input: {
                options?: {
                    include_frames?: bool,
                    include_layouts?: bool,
                    include_paints?: bool
                }
            }
            output: {
                metrics: [benchmark.MetricResult],
                error?: string
            }

        CollectJavaScriptMetrics:
            input: {
                options?: {
                    include_gc?: bool,
                    include_execution?: bool,
                    include_compilation?: bool
                }
            }
            output: {
                metrics: [benchmark.MetricResult],
                error?: string
            }

        CollectMemoryMetrics:
            input: {
                options?: {
                    include_heap?: bool,
                    include_dom?: bool,
                    include_resources?: bool
                }
            }
            output: {
                metrics: [benchmark.MetricResult],
                error?: string
            }

        CollectNetworkMetrics:
            input: {
                options?: {
                    include_timing?: bool,
                    include_size?: bool,
                    include_protocols?: bool
                }
            }
            output: {
                metrics: [benchmark.MetricResult],
                error?: string
            }

        CollectInteractionMetrics:
            input: {
                options?: {
                    include_input?: bool,
                    include_animation?: bool,
                    include_response?: bool
                }
            }
            output: {
                metrics: [benchmark.MetricResult],
                error?: string
            }

        StartTrace:
            input: {
                categories: [string],
                buffer_size?: int
            }
            output: {
                trace_id: string,
                error?: string
            }

        StopTrace:
            input: {
                trace_id: string
            }
            output: {
                trace?: benchmark.PerformanceTrace,
                error?: string
            }

-rules
    MetricValidation:
        when: metric_collection
        validate:
            - verify_metric_type
            - check_collection_options
            - validate_environment
        actions:
            - setup_collectors
            - gather_metrics
            - process_results

    TraceManagement:
        when: trace_state_change
        validate:
            - verify_categories
            - check_buffer
            - validate_state
        actions:
            - update_trace_state
            - process_events
            - store_trace

    DataProcessing:
        when: data_collected
        validate:
            - verify_data_format
            - check_completeness
            - validate_values
        actions:
            - calculate_metrics
            - aggregate_results
            - store_data
