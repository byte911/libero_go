-schema=security_test_runner_api
    version = 1.0

-import
    security = "../types/security_test.l"

-api
    SecurityTestRunner:
        RunSecurityTest:
            input: {
                test: security.SecurityTest,
                options?: {
                    parallel?: bool,
                    timeout?: int,
                    cleanup?: bool
                }
            }
            output: {
                report?: security.SecurityReport,
                error?: string
            }

        RunVulnerabilityTest:
            input: {
                test: security.VulnerabilityTest,
                context?: object
            }
            output: {
                vulnerability?: security.SecurityVulnerability,
                error?: string
            }

        ValidatePayload:
            input: {
                payload: security.Payload,
                context: object
            }
            output: {
                valid: bool,
                issues: [string]
            }

        ExecuteCleanup:
            input: {
                cleanup: security.CleanupAction,
                context: object
            }
            output: {
                success: bool,
                error?: string
            }

        GenerateReport:
            input: {
                vulnerabilities: [security.SecurityVulnerability],
                options?: {
                    include_evidence?: bool,
                    include_recommendations?: bool
                }
            }
            output: {
                report?: security.SecurityReport,
                error?: string
            }

        AnalyzeVulnerability:
            input: {
                vulnerability: security.SecurityVulnerability
            }
            output: {
                recommendation?: security.SecurityRecommendation,
                error?: string
            }

-rules
    TestExecution:
        when: security_test_started
        validate:
            - verify_test_configuration
            - check_dependencies
            - validate_environment
        actions:
            - setup_security_context
            - execute_tests
            - collect_results

    VulnerabilityValidation:
        when: vulnerability_detected
        validate:
            - verify_evidence
            - check_severity
            - validate_impact
        actions:
            - document_vulnerability
            - analyze_risk
            - suggest_remediation

    CleanupManagement:
        when: cleanup_needed
        validate:
            - verify_cleanup_actions
            - check_dependencies
            - validate_state
        actions:
            - execute_cleanup
            - verify_restoration
            - document_changes
