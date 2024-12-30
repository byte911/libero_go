-schema=error_analyzer_api
    version = 1.0

-import
    error = "../types/error.l"

-api
    ErrorAnalyzer:
        AnalyzePattern:
            input: {
                errors: [error.Error],
                options?: {
                    window?: int,
                    min_occurrences?: int
                }
            }
            output: {
                patterns: [error.ErrorPattern],
                error?: string
            }

        DetectTrends:
            input: {
                errors: [error.Error],
                period: string,
                metrics: [string]
            }
            output: {
                trends: [error.ErrorTrend],
                error?: string
            }

        ClassifyErrors:
            input: {
                errors: [error.Error],
                criteria?: object
            }
            output: {
                classifications: object,
                error?: string
            }

        CorrelateErrors:
            input: {
                errors: [error.Error],
                context: object,
                window: int
            }
            output: {
                correlations: [object],
                error?: string
            }

        GenerateInsights:
            input: {
                errors: [error.Error],
                metrics: error.ErrorMetrics
            }
            output: {
                recommendations: [error.ErrorRecommendation],
                error?: string
            }

        PredictErrors:
            input: {
                historical: [error.Error],
                window: string
            }
            output: {
                predictions: [object],
                error?: string
            }

-rules
    PatternAnalysis:
        when: analysis_started
        validate:
            - verify_errors
            - check_options
            - validate_window
        actions:
            - identify_patterns
            - calculate_frequencies
            - rank_patterns

    TrendAnalysis:
        when: trend_detection
        validate:
            - verify_period
            - check_metrics
            - validate_data
        actions:
            - analyze_trends
            - detect_anomalies
            - generate_insights

    ErrorPrediction:
        when: prediction_requested
        validate:
            - verify_historical
            - check_window
            - validate_model
        actions:
            - prepare_data
            - train_model
            - make_predictions
