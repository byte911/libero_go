-schema=test_manager_api
    version = 1.0

-import
    testing = "../types/testing.l"

-api
    TestManager:
        CreateTest:
            input: {
                test: testing.Test
            }
            output: {
                test_id: string,
                error?: string
            }

        CreateSuite:
            input: {
                suite: testing.TestSuite
            }
            output: {
                suite_id: string,
                error?: string
            }

        RunTest:
            input: {
                test_id: string,
                config?: testing.TestConfig
            }
            output: {
                result?: testing.TestResult,
                error?: string
            }

        RunSuite:
            input: {
                suite_id: string,
                config?: testing.TestConfig
            }
            output: {
                run_id: string,
                error?: string
            }

        GetRunStatus:
            input: {
                run_id: string
            }
            output: {
                status?: testing.RunStatus,
                results?: [testing.TestResult],
                error?: string
            }

        AddDependency:
            input: {
                test_id: string,
                dependency: testing.TestDependency
            }
            output: {
                success: bool,
                error?: string
            }

        SetupFixture:
            input: {
                fixture: testing.TestFixture
            }
            output: {
                fixture_id: string,
                error?: string
            }

        ConfigureMock:
            input: {
                mock: testing.TestMock
            }
            output: {
                mock_id: string,
                error?: string
            }

        GenerateReport:
            input: {
                run_id: string,
                options?: {
                    include_coverage?: bool
                }
            }
            output: {
                report?: testing.TestReport,
                error?: string
            }

-rules
    TestExecution:
        when: test_started
        validate:
            - verify_test
            - check_dependencies
            - validate_config
        actions:
            - setup_environment
            - run_steps
            - verify_assertions

    SuiteExecution:
        when: suite_started
        validate:
            - verify_suite
            - check_tests
            - validate_parallel
        actions:
            - schedule_tests
            - track_progress
            - collect_results

    DependencyManagement:
        when: dependency_added
        validate:
            - verify_dependency
            - check_availability
            - validate_config
        actions:
            - setup_dependency
            - verify_setup
            - cleanup_after
