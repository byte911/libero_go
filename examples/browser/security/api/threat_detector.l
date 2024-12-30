-schema=threat_detector_api
    version = 1.0

-import
    security = "../types/security.l"

-api
    ThreatDetector:
        DetectThreats:
            input: {
                events: [security.SecurityEvent],
                rules: [security.SecurityRule]
            }
            output: {
                threats: [security.ThreatInfo],
                error?: string
            }

        AnalyzeBehavior:
            input: {
                context: security.SecurityContext,
                timerange: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                anomalies: [object],
                error?: string
            }

        ScanResource:
            input: {
                resource: security.Resource,
                checks: [security.SecurityCheck]
            }
            output: {
                findings: [object],
                error?: string
            }

        EvaluateRisk:
            input: {
                context: security.SecurityContext,
                threats: [security.ThreatInfo]
            }
            output: {
                risk_level: string,
                factors: [object],
                error?: string
            }

        MonitorActivity:
            input: {
                subject: security.Subject,
                patterns: [string]
            }
            output: {
                matches: [object],
                error?: string
            }

        GenerateAlert:
            input: {
                threat: security.ThreatInfo,
                severity: security.Severity
            }
            output: {
                alert_id: string,
                error?: string
            }

-rules
    ThreatDetection:
        when: detection_started
        validate:
            - verify_events
            - check_rules
            - validate_patterns
        actions:
            - analyze_events
            - detect_threats
            - generate_alerts

    BehaviorAnalysis:
        when: analysis_started
        validate:
            - verify_context
            - check_timerange
            - validate_data
        actions:
            - analyze_behavior
            - detect_anomalies
            - assess_risk

    ResourceScanning:
        when: scan_started
        validate:
            - verify_resource
            - check_checks
            - validate_scope
        actions:
            - scan_resource
            - analyze_findings
            - report_results
