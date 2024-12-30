-schema=automation_test_runner_api
    version = 1.0

-import
    automation = "../types/automation_test.l"

-api
    AutomationTestRunner:
        RunAutomationTest:
            input: {
                test: automation.AutomationTest,
                options?: {
                    parallel?: bool,
                    retry?: bool,
                    screenshot?: bool
                }
            }
            output: {
                result?: automation.AutomationResult,
                error?: string
            }

        SetupEnvironment:
            input: {
                environment: automation.Environment
            }
            output: {
                success: bool,
                error?: string
            }

        ExecuteStep:
            input: {
                step: automation.TestStep,
                context: object
            }
            output: {
                result?: automation.StepResult,
                error?: string
            }

        ValidateAssertion:
            input: {
                assertion: automation.Assertion,
                context: object
            }
            output: {
                result?: automation.AssertionResult,
                error?: string
            }

        CaptureScreenshot:
            input: {
                context: string,
                metadata?: object
            }
            output: {
                screenshot?: automation.Screenshot,
                error?: string
            }

        HandleRetry:
            input: {
                policy: automation.RetryPolicy,
                error: string
            }
            output: {
                should_retry: bool,
                wait_time: int
            }

        GenerateReport:
            input: {
                results: [automation.AutomationResult],
                options?: {
                    format?: string,
                    include_screenshots?: bool,
                    include_logs?: bool
                }
            }
            output: {
                report?: automation.AutomationReport,
                error?: string
            }

-rules
    TestExecution:
        when: automation_test_started
        validate:
            - verify_environment
            - check_dependencies
            - validate_test_data
        actions:
            - setup_environment
            - execute_steps
            - collect_results

    StepExecution:
        when: step_execution
        validate:
            - verify_element
            - check_conditions
            - validate_action
        actions:
            - execute_action
            - handle_retry
            - capture_screenshot

    AssertionValidation:
        when: assertion_validation
        validate:
            - verify_condition
            - check_timeout
            - validate_value
        actions:
            - evaluate_assertion
            - record_result
            - handle_failure
