-schema=performance_manager_api
    version = 1.0

-import
    performance = "../types/performance.l"

-api
    PerformanceManager:
        CollectMetrics:
            input: {
                metrics: [performance.MetricDefinition],
                interval: int
            }
            output: {
                metrics: [performance.Performance],
                error?: string
            }

        RunBenchmark:
            input: {
                benchmark: performance.Benchmark
            }
            output: {
                results: [performance.Performance],
                error?: string
            }

        StartProfiling:
            input: {
                type: performance.ProfileType,
                duration: int
            }
            output: {
                profile_id: string,
                error?: string
            }

        StopProfiling:
            input: {
                profile_id: string
            }
            output: {
                profile?: performance.Profile,
                error?: string
            }

        StartTrace:
            input: {
                name: string,
                tags?: [string]
            }
            output: {
                trace_id: string,
                error?: string
            }

        EndTrace:
            input: {
                trace_id: string
            }
            output: {
                trace?: performance.Trace,
                error?: string
            }

        AnalyzePerformance:
            input: {
                data: {
                    metrics?: [performance.Performance],
                    profiles?: [performance.Profile],
                    traces?: [performance.Trace]
                }
            }
            output: {
                insights: [performance.PerformanceInsight],
                error?: string
            }

        GenerateReport:
            input: {
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                options?: {
                    include_profiles?: bool,
                    include_traces?: bool
                }
            }
            output: {
                report?: performance.PerformanceReport,
                error?: string
            }

-rules
    MetricsCollection:
        when: collection_started
        validate:
            - verify_metrics
            - check_interval
            - validate_access
        actions:
            - collect_metrics
            - process_data
            - store_results

    BenchmarkExecution:
        when: benchmark_started
        validate:
            - verify_benchmark
            - check_config
            - validate_environment
        actions:
            - setup_benchmark
            - run_tests
            - collect_results

    ProfilingManagement:
        when: profiling_requested
        validate:
            - verify_type
            - check_duration
            - validate_resources
        actions:
            - start_profiling
            - collect_samples
            - analyze_data
