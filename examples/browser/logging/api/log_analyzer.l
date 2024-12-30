-schema=log_analyzer_api
    version = 1.0

-import
    logging = "../types/logging.l"

-api
    LogAnalyzer:
        AnalyzeLogs:
            input: {
                records: [logging.LogRecord],
                options?: {
                    group_by?: string,
                    metrics?: [string]
                }
            }
            output: {
                stats?: logging.LogStats,
                error?: string
            }

        DetectTrends:
            input: {
                records: [logging.LogRecord],
                metrics: [string],
                interval: string
            }
            output: {
                trends: [logging.LogTrend],
                error?: string
            }

        DetectAnomalies:
            input: {
                records: [logging.LogRecord],
                baseline?: object,
                threshold?: float
            }
            output: {
                alerts: [logging.LogAlert],
                error?: string
            }

        CorrelateEvents:
            input: {
                records: [logging.LogRecord],
                pattern: string,
                window: int
            }
            output: {
                correlations: [object],
                error?: string
            }

        GenerateReport:
            input: {
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                options?: {
                    include_trends?: bool,
                    include_alerts?: bool
                }
            }
            output: {
                report?: logging.LogReport,
                error?: string
            }

        ExportLogs:
            input: {
                records: [logging.LogRecord],
                format: string,
                options?: object
            }
            output: {
                content: string,
                error?: string
            }

-rules
    AnalysisExecution:
        when: analysis_started
        validate:
            - verify_records
            - check_metrics
            - validate_options
        actions:
            - analyze_data
            - calculate_stats
            - detect_patterns

    TrendDetection:
        when: trend_detection
        validate:
            - verify_metrics
            - check_interval
            - validate_data
        actions:
            - identify_trends
            - analyze_patterns
            - generate_insights

    AnomalyDetection:
        when: anomaly_detection
        validate:
            - verify_baseline
            - check_threshold
            - validate_records
        actions:
            - detect_anomalies
            - assess_severity
            - generate_alerts
