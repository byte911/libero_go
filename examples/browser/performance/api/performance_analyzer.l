-schema=performance_analyzer_api
    version = 1.0

-import
    performance = "../types/performance.l"

-api
    PerformanceAnalyzer:
        AnalyzeMetrics:
            input: {
                metrics: [performance.Performance],
                thresholds?: [performance.Threshold]
            }
            output: {
                insights: [performance.PerformanceInsight],
                error?: string
            }

        AnalyzeProfile:
            input: {
                profile: performance.Profile,
                options?: {
                    threshold?: float,
                    depth?: int
                }
            }
            output: {
                insights: [performance.ProfileInsight],
                error?: string
            }

        AnalyzeTrace:
            input: {
                trace: performance.Trace,
                options?: {
                    min_duration?: int,
                    max_spans?: int
                }
            }
            output: {
                bottlenecks: [object],
                error?: string
            }

        DetectAnomalies:
            input: {
                metrics: [performance.Performance],
                baseline?: object
            }
            output: {
                anomalies: [object],
                error?: string
            }

        PredictTrends:
            input: {
                metrics: [performance.Performance],
                window: string
            }
            output: {
                predictions: [object],
                error?: string
            }

        OptimizePerformance:
            input: {
                insights: [performance.PerformanceInsight],
                constraints?: object
            }
            output: {
                recommendations: [object],
                error?: string
            }

-rules
    MetricsAnalysis:
        when: analysis_started
        validate:
            - verify_metrics
            - check_thresholds
            - validate_data
        actions:
            - analyze_trends
            - detect_patterns
            - generate_insights

    ProfileAnalysis:
        when: profile_analysis
        validate:
            - verify_profile
            - check_options
            - validate_samples
        actions:
            - analyze_samples
            - identify_hotspots
            - generate_insights

    TraceAnalysis:
        when: trace_analysis
        validate:
            - verify_trace
            - check_spans
            - validate_duration
        actions:
            - analyze_spans
            - detect_bottlenecks
            - generate_report
