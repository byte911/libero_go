-schema=test_runner_api
    version = 1.0

-import
    test = "../types/test.l"
    reporter = "../types/reporter.l"

-api
    TestRunner:
        RunSuite:
            input: {
                suite: test.TestSuite,
                options?: {
                    parallel?: bool,
                    max_workers?: int,
                    timeout?: int,
                    retry_failed?: bool
                }
            }
            output: {
                report?: reporter.TestReport,
                error?: string
            }

        RunTest:
            input: {
                test: test.Test,
                options?: {
                    timeout?: int,
                    retry?: bool
                }
            }
            output: {
                result?: test.TestResult,
                error?: string
            }

        RunStep:
            input: {
                step: test.TestStep,
                context: object
            }
            output: {
                success: bool,
                error?: string
            }

        SetupFixture:
            input: {
                fixture: test.TestFixture
            }
            output: {
                data?: any,
                error?: string
            }

        TeardownFixture:
            input: {
                fixture: test.TestFixture
            }
            output: {
                success: bool,
                error?: string
            }

        CollectCoverage:
            input: {
                options?: {
                    include?: [string],
                    exclude?: [string]
                }
            }
            output: {
                coverage?: test.Coverage,
                error?: string
            }

        GenerateReport:
            input: {
                results: [test.TestResult],
                format: reporter.ReportFormat,
                options?: {
                    include_screenshots?: bool,
                    include_logs?: bool,
                    include_coverage?: bool
                }
            }
            output: {
                report?: reporter.TestReport,
                error?: string
            }

-rules
    TestExecution:
        when: test_started
        validate:
            - verify_test_definition
            - check_dependencies
            - validate_fixtures
        actions:
            - setup_environment
            - run_before_hooks
            - execute_steps

    TestValidation:
        when: step_completed
        validate:
            - verify_step_result
            - check_expectations
            - validate_timeouts
        actions:
            - record_result
            - capture_screenshots
            - update_coverage

    ReportGeneration:
        when: suite_completed
        validate:
            - verify_results
            - check_coverage
            - validate_metrics
        actions:
            - aggregate_results
            - generate_report
            - cleanup_resources
