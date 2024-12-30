-schema=debugger_manager_api
    version = 1.0

-import
    debugger = "../types/debugger.l"

-api
    DebuggerManager:
        Enable:
            input: {}
            output: {
                success: bool,
                error?: string
            }

        Disable:
            input: {}
            output: {
                success: bool,
                error?: string
            }

        SetBreakpoint:
            input: {
                type: debugger.BreakpointType,
                location: debugger.SourceLocation,
                condition?: string
            }
            output: {
                breakpoint?: debugger.Breakpoint,
                error?: string
            }

        RemoveBreakpoint:
            input: {
                id: string
            }
            output: {
                success: bool,
                error?: string
            }

        SetDOMBreakpoint:
            input: {
                node: string,
                type: debugger.DOMBreakpointType
            }
            output: {
                breakpoint?: debugger.DOMBreakpoint,
                error?: string
            }

        SetEventBreakpoint:
            input: {
                type: string,
                category: string
            }
            output: {
                breakpoint?: debugger.EventBreakpoint,
                error?: string
            }

        SetXHRBreakpoint:
            input: {
                url: string
            }
            output: {
                breakpoint?: debugger.XHRBreakpoint,
                error?: string
            }

        Resume:
            input: {}
            output: {
                success: bool,
                error?: string
            }

        StepOver:
            input: {}
            output: {
                success: bool,
                error?: string
            }

        StepInto:
            input: {}
            output: {
                success: bool,
                error?: string
            }

        StepOut:
            input: {}
            output: {
                success: bool,
                error?: string
            }

        Pause:
            input: {}
            output: {
                success: bool,
                error?: string
            }

        GetStackTrace:
            input: {}
            output: {
                frames: debugger.StackFrame[],
                error?: string
            }

        EvaluateExpression:
            input: {
                expression: string,
                frame_id?: string
            }
            output: {
                result?: any,
                error?: string
            }

        GetScopeVariables:
            input: {
                scope_id: string
            }
            output: {
                variables: object,
                error?: string
            }

-rules
    BreakpointHit:
        when: breakpoint_reached
        validate:
            - verify_breakpoint_condition
            - check_hit_count
            - validate_pause_state
        actions:
            - pause_execution
            - collect_debug_info
            - notify_client

    ExceptionCaught:
        when: exception_thrown
        validate:
            - check_exception_type
            - verify_break_on_exceptions
            - validate_pause_state
        actions:
            - pause_execution
            - collect_exception_info
            - notify_client

    StepCompleted:
        when: step_finished
        validate:
            - verify_step_type
            - check_location
            - validate_pause_state
        actions:
            - pause_execution
            - collect_debug_info
            - notify_client
