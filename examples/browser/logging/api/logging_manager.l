-schema=logging_manager_api
    version = 1.0

-import
    logging = "../types/logging.l"

-api
    LoggingManager:
        CreateLogger:
            input: {
                name: string,
                config: {
                    level: logging.LogLevel,
                    handlers?: [logging.LogHandler],
                    filters?: [logging.LogFilter]
                }
            }
            output: {
                logger_id: string,
                error?: string
            }

        Log:
            input: {
                logger_id: string,
                level: logging.LogLevel,
                message: string,
                context?: object
            }
            output: {
                record_id: string,
                error?: string
            }

        AddHandler:
            input: {
                logger_id: string,
                handler: logging.LogHandler
            }
            output: {
                success: bool,
                error?: string
            }

        AddFilter:
            input: {
                logger_id: string,
                filter: logging.LogFilter
            }
            output: {
                success: bool,
                error?: string
            }

        SetLevel:
            input: {
                logger_id: string,
                level: logging.LogLevel
            }
            output: {
                success: bool,
                error?: string
            }

        Flush:
            input: {
                logger_id: string
            }
            output: {
                success: bool,
                error?: string
            }

        Query:
            input: {
                query: logging.LogQuery
            }
            output: {
                records: [logging.LogRecord],
                error?: string
            }

        GetStats:
            input: {
                timerange: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                stats?: logging.LogStats,
                error?: string
            }

-rules
    LoggerManagement:
        when: logger_created
        validate:
            - verify_config
            - check_handlers
            - validate_filters
        actions:
            - create_logger
            - setup_handlers
            - apply_filters

    LogProcessing:
        when: log_received
        validate:
            - verify_level
            - check_context
            - validate_message
        actions:
            - process_record
            - apply_filters
            - dispatch_handlers

    QueryExecution:
        when: query_requested
        validate:
            - verify_timerange
            - check_patterns
            - validate_context
        actions:
            - execute_query
            - filter_results
            - format_output
