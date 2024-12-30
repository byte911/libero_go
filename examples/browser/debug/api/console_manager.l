-schema=console_manager_api
    version = 1.0

-import
    debugger = "../types/debugger.l"

-api
    ConsoleManager:
        Log:
            input: {
                level: debugger.MessageLevel,
                message: string,
                args?: [any]
            }
            output: {
                message?: debugger.ConsoleMessage,
                error?: string
            }

        Clear:
            input: {}
            output: {
                success: bool,
                error?: string
            }

        StartViolationReporting:
            input: {
                types: [string]  # e.g., ["layout", "long-task", "memory"]
            }
            output: {
                success: bool,
                error?: string
            }

        StopViolationReporting:
            input: {
                types?: [string]
            }
            output: {
                success: bool,
                error?: string
            }

        GetMessages:
            input: {
                filter?: {
                    level?: debugger.MessageLevel,
                    source?: string,
                    text?: string
                },
                limit?: int,
                offset?: int
            }
            output: {
                messages: debugger.ConsoleMessage[],
                total: int,
                has_more: bool
            }

        CreateTimer:
            input: {
                name: string
            }
            output: {
                timer_id: string,
                error?: string
            }

        StopTimer:
            input: {
                timer_id: string
            }
            output: {
                duration: float,
                error?: string
            }

        TraceStack:
            input: {
                message?: string
            }
            output: {
                stack: debugger.StackFrame[],
                error?: string
            }

        Assert:
            input: {
                condition: bool,
                message?: string
            }
            output: {
                message?: debugger.ConsoleMessage,
                error?: string
            }

        Count:
            input: {
                label?: string
            }
            output: {
                count: int,
                error?: string
            }

-rules
    MessageFormatting:
        when: message_logged
        validate:
            - verify_message_level
            - check_argument_types
            - validate_format_string
        actions:
            - format_message
            - add_stack_trace
            - notify_listeners

    ViolationDetection:
        when: violation_detected
        validate:
            - verify_violation_type
            - check_threshold
            - validate_context
        actions:
            - record_violation
            - analyze_impact
            - notify_violation

    ConsoleState:
        when: console_state_change
        validate:
            - verify_state_transition
            - check_buffer_size
            - validate_persistence
        actions:
            - update_state
            - cleanup_if_needed
            - notify_state_change
