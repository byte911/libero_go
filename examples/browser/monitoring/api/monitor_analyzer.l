-schema=monitor_analyzer_api
    version = 1.0

-import
    monitoring = "../types/monitoring.l"

-api
    MonitorAnalyzer:
        AnalyzeMetrics:
            input: {
                metrics: [monitoring.MetricData],
                options?: {
                    window?: int,
                    aggregation?: string
                }
            }
            output: {
                analysis: object,
                error?: string
            }

        DetectAnomalies:
            input: {
                metrics: [monitoring.MetricData],
                baseline?: object,
                sensitivity?: float
            }
            output: {
                anomalies: [object],
                error?: string
            }

        AnalyzeTrends:
            input: {
                metrics: [monitoring.MetricData],
                period: string
            }
            output: {
                trends: [object],
                error?: string
            }

        CorrelateEvents:
            input: {
                metrics: [monitoring.MetricData],
                events: [monitoring.MonitorEvent],
                window: int
            }
            output: {
                correlations: [object],
                error?: string
            }

        PredictMetrics:
            input: {
                metrics: [monitoring.MetricData],
                horizon: string,
                model?: string
            }
            output: {
                predictions: [object],
                error?: string
            }

        GenerateInsights:
            input: {
                metrics: [monitoring.MetricData],
                alerts: [monitoring.Alert],
                options?: object
            }
            output: {
                insights: [object],
                error?: string
            }

-rules
    MetricsAnalysis:
        when: analysis_started
        validate:
            - verify_metrics
            - check_options
            - validate_data
        actions:
            - analyze_metrics
            - detect_patterns
            - generate_insights

    AnomalyDetection:
        when: anomaly_detection
        validate:
            - verify_metrics
            - check_baseline
            - validate_sensitivity
        actions:
            - detect_anomalies
            - analyze_severity
            - generate_alerts

    TrendAnalysis:
        when: trend_analysis
        validate:
            - verify_metrics
            - check_period
            - validate_data
        actions:
            - analyze_trends
            - detect_patterns
            - generate_report
