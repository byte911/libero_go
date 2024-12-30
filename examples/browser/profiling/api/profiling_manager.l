-schema=profiling_manager_api
    version = 1.0

-import
    profiling = "../types/profiling.l"

-api
    ProfilingManager:
        StartProfiling:
            input: {
                profile: profiling.Profile,
                options?: {
                    async?: bool,
                    buffer_size?: int
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
                data?: profiling.ProfileData,
                error?: string
            }

        TakeHeapSnapshot:
            input: {
                target: profiling.ProfileTarget,
                options?: {
                    detailed?: bool,
                    gc_first?: bool
                }
            }
            output: {
                snapshot?: profiling.HeapSnapshot,
                error?: string
            }

        CaptureTimeline:
            input: {
                duration: int,
                categories: [string]
            }
            output: {
                trace?: profiling.TimelineTrace,
                error?: string
            }

        AnalyzeProfile:
            input: {
                data: profiling.ProfileData,
                metrics: [string]
            }
            output: {
                summary?: profiling.ProfileSummary,
                error?: string
            }

        FindHotspots:
            input: {
                data: profiling.ProfileData,
                threshold: float
            }
            output: {
                hotspots: [profiling.Hotspot],
                error?: string
            }

        GenerateRecommendations:
            input: {
                profile: profiling.ProfileSummary,
                context: object
            }
            output: {
                recommendations: [profiling.Recommendation],
                error?: string
            }

        GenerateReport:
            input: {
                profiles: [profiling.ProfileData],
                options?: {
                    format?: string,
                    include_recommendations?: bool
                }
            }
            output: {
                report?: profiling.ProfilingReport,
                error?: string
            }

-rules
    ProfilingExecution:
        when: profiling_started
        validate:
            - verify_profile_config
            - check_permissions
            - validate_target
        actions:
            - setup_profiler
            - start_sampling
            - collect_data

    DataAnalysis:
        when: analysis_requested
        validate:
            - verify_data_format
            - check_metrics
            - validate_thresholds
        actions:
            - analyze_samples
            - find_hotspots
            - generate_recommendations

    ReportGeneration:
        when: report_requested
        validate:
            - verify_profiles
            - check_format
            - validate_options
        actions:
            - compile_data
            - format_report
            - add_recommendations
