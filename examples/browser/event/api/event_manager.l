-schema=event_manager_api
    version = 1.0

-import
    event = "../types/event.l"

-api
    EventManager:
        PublishEvent:
            input: {
                event: event.Event
            }
            output: {
                event_id: string,
                error?: string
            }

        SubscribeEvents:
            input: {
                subscription: event.EventSubscription
            }
            output: {
                subscription_id: string,
                error?: string
            }

        RegisterHandler:
            input: {
                handler: event.EventHandler
            }
            output: {
                handler_id: string,
                error?: string
            }

        CreateStream:
            input: {
                stream: event.EventStream
            }
            output: {
                stream_id: string,
                error?: string
            }

        RegisterPattern:
            input: {
                pattern: event.EventPattern
            }
            output: {
                pattern_id: string,
                error?: string
            }

        GetEvents:
            input: {
                filters: [event.EventFilter],
                timerange: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                events: [event.Event],
                error?: string
            }

        GetMetrics:
            input: {
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                group_by?: [string]
            }
            output: {
                metrics?: event.EventMetrics,
                error?: string
            }

        GenerateReport:
            input: {
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                options?: {
                    include_patterns?: bool,
                    include_issues?: bool
                }
            }
            output: {
                report?: event.EventReport,
                error?: string
            }

-rules
    EventProcessing:
        when: event_received
        validate:
            - verify_event
            - check_schema
            - validate_data
        actions:
            - process_event
            - notify_handlers
            - update_metrics

    SubscriptionManagement:
        when: subscription_updated
        validate:
            - verify_subscriber
            - check_filters
            - validate_config
        actions:
            - update_subscription
            - notify_changes
            - sync_state

    PatternMatching:
        when: pattern_evaluation
        validate:
            - verify_sequence
            - check_window
            - validate_events
        actions:
            - evaluate_pattern
            - detect_matches
            - notify_matches
