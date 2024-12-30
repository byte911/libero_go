-schema=event_processor_api
    version = 1.0

-import
    event = "../types/event.l"

-api
    EventProcessor:
        ProcessEvent:
            input: {
                event: event.Event,
                handlers: [event.EventHandler]
            }
            output: {
                results: [object],
                error?: string
            }

        BatchProcess:
            input: {
                batch: event.EventBatch,
                config?: object
            }
            output: {
                processed: int,
                failed: int,
                error?: string
            }

        TransformEvent:
            input: {
                event: event.Event,
                transformation: string,
                params?: object
            }
            output: {
                transformed?: event.Event,
                error?: string
            }

        AggregateEvents:
            input: {
                events: [event.Event],
                aggregation: string,
                window?: int
            }
            output: {
                result?: object,
                error?: string
            }

        CorrelateEvents:
            input: {
                events: [event.Event],
                pattern: event.EventPattern
            }
            output: {
                matches: [event.PatternMatch],
                error?: string
            }

        EnrichEvent:
            input: {
                event: event.Event,
                enrichments: [string],
                context?: object
            }
            output: {
                enriched?: event.Event,
                error?: string
            }

-rules
    EventProcessing:
        when: processing_started
        validate:
            - verify_event
            - check_handlers
            - validate_context
        actions:
            - process_event
            - collect_results
            - handle_errors

    BatchProcessing:
        when: batch_started
        validate:
            - verify_batch
            - check_config
            - validate_size
        actions:
            - process_batch
            - track_progress
            - report_status

    TransformationExecution:
        when: transform_requested
        validate:
            - verify_transformation
            - check_params
            - validate_event
        actions:
            - apply_transform
            - validate_result
            - update_metadata
