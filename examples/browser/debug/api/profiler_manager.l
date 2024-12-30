-schema=profiler_manager_api
    version = 1.0

-import
    profiler = "../types/profiler.l"

-api
    ProfilerManager:
        StartProfiling:
            input: {
                type: profiler.ProfileType,
                options?: {
                    sampling_interval?: int,
                    call_stack_size?: int
                }
            }
            output: {
                profile_id: string,
                error?: string
            }

        StopProfiling:
            input: {
                profile_id: string
            }
            output: {
                profile?: profiler.Profile,
                error?: string
            }

        GetProfile:
            input: {
                profile_id: string
            }
            output: {
                profile?: profiler.Profile,
                error?: string
            }

        TakeHeapSnapshot:
            input: {
                options?: {
                    treat_global_objects_as_roots?: bool,
                    capture_numeric_value?: bool
                }
            }
            output: {
                snapshot?: profiler.HeapSnapshot,
                error?: string
            }

        GetHeapSnapshot:
            input: {
                snapshot_id: string
            }
            output: {
                snapshot?: profiler.HeapSnapshot,
                error?: string
            }

        CompareHeapSnapshots:
            input: {
                snapshot1_id: string,
                snapshot2_id: string
            }
            output: {
                diff: {
                    added: [profiler.HeapNode],
                    removed: [profiler.HeapNode],
                    changed: [{
                        node: profiler.HeapNode,
                        size_delta: int
                    }]
                },
                error?: string
            }

        StartHeapTracking:
            input: {
                options?: {
                    sampling_interval?: int,
                    stack_depth?: int
                }
            }
            output: {
                tracking_id: string,
                error?: string
            }

        StopHeapTracking:
            input: {
                tracking_id: string
            }
            output: {
                samples: [profiler.HeapSample],
                error?: string
            }

        StartCoverage:
            input: {
                options?: {
                    detailed?: bool,
                    include_binary?: bool
                }
            }
            output: {
                success: bool,
                error?: string
            }

        StopCoverage:
            input: {}
            output: {
                coverage: [profiler.Coverage],
                error?: string
            }

        GetBestPractices:
            input: {
                profile_id: string
            }
            output: {
                recommendations: [{
                    type: string,
                    description: string,
                    impact: string,
                    location?: profiler.SourceLocation
                }],
                error?: string
            }

-rules
    ProfilingControl:
        when: profiling_state_change
        validate:
            - verify_profile_type
            - check_resources
            - validate_options
        actions:
            - update_profiling_state
            - collect_samples
            - notify_progress

    HeapAnalysis:
        when: heap_snapshot_taken
        validate:
            - verify_heap_state
            - check_memory_available
            - validate_snapshot_options
        actions:
            - collect_heap_data
            - analyze_references
            - detect_leaks

    CoverageTracking:
        when: coverage_update
        validate:
            - verify_script_state
            - check_instrumentation
            - validate_coverage_data
        actions:
            - update_coverage_info
            - calculate_statistics
            - generate_report
