-schema=benchmark_runner_api
    version = 1.0

-import
    benchmark = "../types/benchmark.l"

-api
    BenchmarkRunner:
        RunBenchmark:
            input: {
                benchmark: benchmark.Benchmark,
                options?: {
                    iterations?: int,
                    warmup?: int,
                    parallel?: bool,
                    collect_traces?: bool
                }
            }
            output: {
                result?: benchmark.BenchmarkResult,
                error?: string
            }

        RunScenario:
            input: {
                scenario: benchmark.Scenario,
                environment: benchmark.EnvironmentSpec
            }
            output: {
                metrics: [benchmark.MetricResult],
                error?: string
            }

        SetupEnvironment:
            input: {
                spec: benchmark.EnvironmentSpec
            }
            output: {
                success: bool,
                error?: string
            }

        CollectMetrics:
            input: {
                definitions: [benchmark.MetricDefinition],
                duration: int
            }
            output: {
                metrics: [benchmark.MetricResult],
                error?: string
            }

        CompareWithBaseline:
            input: {
                current: benchmark.BenchmarkResult,
                baseline: benchmark.BaselineMetrics
            }
            output: {
                comparisons: [benchmark.BaselineComparison],
                regressions: [string],
                error?: string
            }

        UpdateBaseline:
            input: {
                benchmark_id: string,
                result: benchmark.BenchmarkResult
            }
            output: {
                success: bool,
                error?: string
            }

        GenerateReport:
            input: {
                results: [benchmark.BenchmarkResult],
                options?: {
                    format?: string,
                    include_traces?: bool,
                    include_statistics?: bool
                }
            }
            output: {
                report: object,
                error?: string
            }

-rules
    BenchmarkExecution:
        when: benchmark_started
        validate:
            - verify_benchmark_config
            - check_environment
            - validate_metrics
        actions:
            - setup_environment
            - run_warmup
            - collect_metrics

    ScenarioExecution:
        when: scenario_started
        validate:
            - verify_load_profile
            - check_resources
            - validate_steps
        actions:
            - apply_load
            - execute_steps
            - measure_metrics

    MetricCollection:
        when: metric_collection
        validate:
            - verify_metric_definitions
            - check_thresholds
            - validate_samples
        actions:
            - collect_samples
            - calculate_statistics
            - compare_baseline
