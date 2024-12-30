-schema=integration_test_runner_api
    version = 1.0

-import
    integration = "../types/integration_test.l"

-api
    IntegrationTestRunner:
        RunIntegrationTest:
            input: {
                test: integration.IntegrationTest,
                options?: {
                    parallel?: bool,
                    timeout?: int,
                    cleanup?: bool
                }
            }
            output: {
                result?: integration.IntegrationResult,
                error?: string
            }

        SetupEnvironment:
            input: {
                environment: integration.TestEnvironment
            }
            output: {
                success: bool,
                error?: string
            }

        StartComponent:
            input: {
                component: integration.Component,
                dependencies?: [string]
            }
            output: {
                status?: integration.ComponentStatus,
                error?: string
            }

        StopComponent:
            input: {
                component: string,
                force?: bool
            }
            output: {
                success: bool,
                error?: string
            }

        ExecuteScenario:
            input: {
                scenario: integration.IntegrationScenario,
                context: object
            }
            output: {
                result?: integration.ScenarioResult,
                error?: string
            }

        ValidateIntegration:
            input: {
                components: [string],
                assertions: [integration.Assertion]
            }
            output: {
                results: [integration.AssertionResult],
                error?: string
            }

        MonitorHealth:
            input: {
                components: [string],
                duration: int
            }
            output: {
                status: {string: integration.ComponentStatus},
                metrics: object,
                error?: string
            }

        GenerateReport:
            input: {
                results: [integration.IntegrationResult],
                options?: {
                    format?: string,
                    include_logs?: bool,
                    include_metrics?: bool
                }
            }
            output: {
                report: object,
                error?: string
            }

-rules
    TestExecution:
        when: integration_test_started
        validate:
            - verify_environment
            - check_dependencies
            - validate_components
        actions:
            - setup_environment
            - start_components
            - execute_scenarios

    ComponentLifecycle:
        when: component_state_change
        validate:
            - verify_dependencies
            - check_resources
            - validate_health
        actions:
            - update_component_state
            - notify_dependents
            - log_state_change

    ScenarioValidation:
        when: scenario_execution
        validate:
            - verify_preconditions
            - check_component_status
            - validate_assertions
        actions:
            - execute_steps
            - validate_results
            - cleanup_if_needed
