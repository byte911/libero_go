-schema=performance_runner_api
    version = 1.0

-import
    test = "../types/test.l"
    reporter = "../types/reporter.l"

-api
    PerformanceRunner:
        RunBenchmark:
            input: {
                test: test.Test,
                options: {
                    iterations: int,
                    warmup?: int,
                    timeout?: int,
                    metrics?: [string]
                }
            }
            output: {
                report?: reporter.PerformanceReport,
                error?: string
            }

        MeasureMetric:
            input: {
                name: string,
                callback: function,
                options?: {
                    samples?: int,
                    unit?: string
                }
            }
            output: {
                metric?: reporter.Metric,
                error?: string
            }

        StartTrace:
            input: {
                categories: [string],
                options?: {
                    buffer_size?: int,
                    sampling_interval?: int
                }
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
                trace?: reporter.PerformanceTrace,
                error?: string
            }

        CaptureScreenshot:
            input: {
                tag: string,
                options?: {
                    full_page?: bool,
                    quality?: int
                }
            }
            output: {
                screenshot?: reporter.Screenshot,
                error?: string
            }

        SetNetworkConditions:
            input: {
                conditions: reporter.NetworkCondition
            }
            output: {
                success: bool,
                error?: string
            }

        CollectMetrics:
            input: {
                metrics: [string],
                duration: int
            }
            output: {
                results: [reporter.Metric],
                error?: string
            }

-rules
    BenchmarkExecution:
        when: benchmark_started
        validate:
            - verify_test_config
            - check_system_state
            - validate_metrics
        actions:
            - setup_environment
            - run_warmup
            - collect_samples

    MetricCollection:
        when: metric_measured
        validate:
            - verify_metric_type
            - check_thresholds
            - validate_samples
        actions:
            - record_measurement
            - analyze_statistics
            - update_report

    TraceManagement:
        when: trace_state_change
        validate:
            - verify_categories
            - check_buffer_size
            - validate_sampling
        actions:
            - update_trace_state
            - process_events
            - store_trace
