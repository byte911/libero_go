-schema=performance_analyzer_api
    version = 1.0

-import
    profiling = "../types/profiling.l"

-api
    PerformanceAnalyzer:
        AnalyzeCPUProfile:
            input: {
                data: profiling.ProfileData,
                options?: {
                    group_by?: string,
                    min_duration?: int
                }
            }
            output: {
                summary?: profiling.ProfileSummary,
                error?: string
            }

        AnalyzeMemoryProfile:
            input: {
                data: profiling.ProfileData,
                options?: {
                    group_by?: string,
                    include_stacks?: bool
                }
            }
            output: {
                summary?: profiling.ProfileSummary,
                error?: string
            }

        AnalyzeHeapSnapshot:
            input: {
                snapshot: profiling.HeapSnapshot,
                options?: {
                    detailed?: bool,
                    group_by?: string
                }
            }
            output: {
                statistics?: profiling.HeapStats,
                error?: string
            }

        AnalyzeTimeline:
            input: {
                trace: profiling.TimelineTrace,
                metrics: [string]
            }
            output: {
                analysis?: object,
                error?: string
            }

        DetectBottlenecks:
            input: {
                data: profiling.ProfileData,
                threshold: float
            }
            output: {
                bottlenecks: [profiling.Hotspot],
                error?: string
            }

        CompareProfiles:
            input: {
                base: profiling.ProfileData,
                target: profiling.ProfileData,
                metrics: [string]
            }
            output: {
                differences: object,
                error?: string
            }

        OptimizationSuggestions:
            input: {
                profile: profiling.ProfileSummary,
                context: object
            }
            output: {
                suggestions: [profiling.Recommendation],
                error?: string
            }

-rules
    ProfileAnalysis:
        when: analysis_started
        validate:
            - verify_profile_data
            - check_metrics
            - validate_options
        actions:
            - analyze_data
            - detect_patterns
            - generate_summary

    BottleneckDetection:
        when: bottleneck_detection
        validate:
            - verify_thresholds
            - check_patterns
            - validate_impact
        actions:
            - identify_bottlenecks
            - assess_impact
            - suggest_improvements

    ProfileComparison:
        when: comparison_started
        validate:
            - verify_compatibility
            - check_metrics
            - validate_differences
        actions:
            - compare_metrics
            - identify_changes
            - assess_impact
