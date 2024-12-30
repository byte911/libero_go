-schema=test_analyzer_api
    version = 1.0

-import
    testing = "../types/testing.l"

-api
    TestAnalyzer:
        AnalyzeResults:
            input: {
                results: [testing.TestResult],
                options?: {
                    group_by?: [string]
                }
            }
            output: {
                summary: testing.TestSummary,
                error?: string
            }

        AnalyzeCoverage:
            input: {
                results: [testing.TestResult],
                targets: [string]
            }
            output: {
                coverage?: testing.TestCoverage,
                error?: string
            }

        DetectFlakiness:
            input: {
                test_id: string,
                runs: [testing.TestResult]
            }
            output: {
                flaky: bool,
                analysis: object,
                error?: string
            }

        AnalyzePerformance:
            input: {
                results: [testing.TestResult],
                baseline?: object
            }
            output: {
                metrics: object,
                trends: [object],
                error?: string
            }

        IdentifyPatterns:
            input: {
                failures: [testing.TestResult],
                timerange: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                patterns: [object],
                error?: string
            }

        GenerateInsights:
            input: {
                results: [testing.TestResult],
                coverage?: testing.TestCoverage
            }
            output: {
                insights: [object],
                error?: string
            }

-rules
    ResultAnalysis:
        when: analysis_started
        validate:
            - verify_results
            - check_options
            - validate_data
        actions:
            - analyze_results
            - calculate_metrics
            - generate_summary

    CoverageAnalysis:
        when: coverage_requested
        validate:
            - verify_results
            - check_targets
            - validate_scope
        actions:
            - analyze_coverage
            - calculate_rates
            - identify_gaps

    PatternDetection:
        when: pattern_analysis
        validate:
            - verify_failures
            - check_timerange
            - validate_data
        actions:
            - analyze_patterns
            - detect_trends
            - generate_insights
