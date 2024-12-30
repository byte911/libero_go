-schema=console_manager_api
    version = 1.0

-import
    debugger = "../types/debugger.l"

-api
    ConsoleManager:
        LogMessage:
            input: {
                message: debugger.ConsoleMessage
            }
            output: {
                success: bool,
                error?: string
            }

        ClearConsole:
            input: {
                filter?: {
                    types?: [debugger.MessageType],
                    source?: string
                }
            }
            output: {
                success: bool,
                error?: string
            }

        GetMessages:
            input: {
                filter?: {
                    types?: [debugger.MessageType],
                    source?: string,
                    timerange?: {
                        start: timestamp,
                        end: timestamp
                    }
                }
            }
            output: {
                messages: [debugger.ConsoleMessage],
                error?: string
            }

        StartCapture:
            input: {
                options?: {
                    types?: [debugger.MessageType],
                    buffer_size?: int
                }
            }
            output: {
                capture_id: string,
                error?: string
            }

        StopCapture:
            input: {
                capture_id: string
            }
            output: {
                messages: [debugger.ConsoleMessage],
                error?: string
            }

        FilterMessages:
            input: {
                pattern: string,
                options?: {
                    case_sensitive?: bool,
                    whole_word?: bool
                }
            }
            output: {
                messages: [debugger.ConsoleMessage],
                error?: string
            }

        ExportMessages:
            input: {
                format: string,
                filter?: object
            }
            output: {
                content: string,
                error?: string
            }

-rules
    MessageHandling:
        when: message_received
        validate:
            - verify_message
            - check_type
            - validate_source
        actions:
            - process_message
            - store_message
            - notify_listeners

    CaptureManagement:
        when: capture_state_change
        validate:
            - verify_options
            - check_buffer
            - validate_state
        actions:
            - update_capture
            - manage_buffer
            - notify_changes

    MessageFiltering:
        when: filter_requested
        validate:
            - verify_pattern
            - check_options
            - validate_filter
        actions:
            - apply_filter
            - sort_results
            - format_output
