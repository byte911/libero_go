-schema=debugger_manager_api
    version = 1.0

-import
    debugger = "../types/debugger.l"

-api
    DebuggerManager:
        StartDebugger:
            input: {
                target: debugger.DebugTarget,
                options?: {
                    break_on_start?: bool,
                    ignore_scripts?: [string]
                }
            }
            output: {
                debugger_id: string,
                error?: string
            }

        StopDebugger:
            input: {
                debugger_id: string
            }
            output: {
                success: bool,
                error?: string
            }

        SetBreakpoint:
            input: {
                debugger_id: string,
                breakpoint: debugger.Breakpoint
            }
            output: {
                id: string,
                error?: string
            }

        RemoveBreakpoint:
            input: {
                debugger_id: string,
                breakpoint_id: string
            }
            output: {
                success: bool,
                error?: string
            }

        ExecuteCommand:
            input: {
                debugger_id: string,
                command: debugger.DebuggerCommand
            }
            output: {
                result?: debugger.EvaluationResult,
                error?: string
            }

        EvaluateExpression:
            input: {
                debugger_id: string,
                expression: string,
                frame_id?: string
            }
            output: {
                result?: debugger.EvaluationResult,
                error?: string
            }

        GetStackTrace:
            input: {
                debugger_id: string
            }
            output: {
                frames: [debugger.StackFrame],
                error?: string
            }

        GetVariables:
            input: {
                frame_id: string,
                scope_type?: debugger.ScopeType
            }
            output: {
                variables: [debugger.Variable],
                error?: string
            }

-rules
    DebuggerExecution:
        when: debugger_started
        validate:
            - verify_target
            - check_permissions
            - validate_options
        actions:
            - setup_debugger
            - attach_handlers
            - initialize_state

    BreakpointManagement:
        when: breakpoint_operation
        validate:
            - verify_location
            - check_condition
            - validate_state
        actions:
            - update_breakpoints
            - notify_client
            - sync_state

    CommandExecution:
        when: command_received
        validate:
            - verify_command
            - check_state
            - validate_context
        actions:
            - execute_command
            - update_state
            - notify_result
