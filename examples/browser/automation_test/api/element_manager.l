-schema=element_manager_api
    version = 1.0

-import
    automation = "../types/automation_test.l"

-api
    ElementManager:
        FindElement:
            input: {
                selector: automation.Element,
                timeout?: int
            }
            output: {
                element?: object,
                error?: string
            }

        WaitForElement:
            input: {
                selector: automation.Element,
                condition: string,
                timeout?: int
            }
            output: {
                success: bool,
                error?: string
            }

        ExecuteAction:
            input: {
                element: object,
                action: automation.Action,
                value?: any
            }
            output: {
                success: bool,
                error?: string
            }

        GetElementState:
            input: {
                element: object,
                properties: [string]
            }
            output: {
                state: object,
                error?: string
            }

        ValidateElement:
            input: {
                element: object,
                assertion: automation.Assertion
            }
            output: {
                result?: automation.AssertionResult,
                error?: string
            }

        ScrollIntoView:
            input: {
                element: object,
                options?: {
                    behavior?: string,
                    block?: string,
                    inline?: string
                }
            }
            output: {
                success: bool,
                error?: string
            }

        GetElementScreenshot:
            input: {
                element: object,
                options?: {
                    full?: bool,
                    quality?: int
                }
            }
            output: {
                screenshot?: automation.Screenshot,
                error?: string
            }

-rules
    ElementLocation:
        when: element_search
        validate:
            - verify_selector
            - check_timeout
            - validate_frame
        actions:
            - locate_element
            - handle_timeout
            - update_cache

    ActionExecution:
        when: action_execution
        validate:
            - verify_element_state
            - check_action_params
            - validate_conditions
        actions:
            - execute_action
            - handle_errors
            - update_state

    StateValidation:
        when: state_validation
        validate:
            - verify_properties
            - check_visibility
            - validate_enabled
        actions:
            - get_state
            - compare_values
            - record_result
