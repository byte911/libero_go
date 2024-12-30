-schema=security_manager_api
    version = 1.0

-import
    security = "../types/security.l"

-api
    SecurityManager:
        CheckAccess:
            input: {
                context: security.SecurityContext,
                permission: security.Permission
            }
            output: {
                allowed: bool,
                reason?: string,
                error?: string
            }

        AuthenticateSubject:
            input: {
                subject: security.Subject,
                credentials: security.Credentials
            }
            output: {
                authenticated: bool,
                context?: security.SecurityContext,
                error?: string
            }

        RegisterPolicy:
            input: {
                policy: security.Policy
            }
            output: {
                policy_id: string,
                error?: string
            }

        EvaluatePolicy:
            input: {
                context: security.SecurityContext,
                policies: [security.Policy]
            }
            output: {
                effect: security.PolicyEffect,
                matches: [string],
                error?: string
            }

        RecordEvent:
            input: {
                event: security.SecurityEvent
            }
            output: {
                event_id: string,
                error?: string
            }

        PerformCheck:
            input: {
                check: security.SecurityCheck,
                context?: security.SecurityContext
            }
            output: {
                passed: bool,
                findings: [object],
                error?: string
            }

        GetMetrics:
            input: {
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                group_by?: [string]
            }
            output: {
                metrics?: security.SecurityMetrics,
                error?: string
            }

        GenerateReport:
            input: {
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                options?: {
                    include_events?: bool,
                    include_threats?: bool
                }
            }
            output: {
                report?: security.SecurityReport,
                error?: string
            }

-rules
    AccessControl:
        when: access_requested
        validate:
            - verify_context
            - check_permission
            - validate_conditions
        actions:
            - evaluate_policies
            - record_decision
            - notify_result

    Authentication:
        when: auth_requested
        validate:
            - verify_subject
            - check_credentials
            - validate_expiry
        actions:
            - authenticate_subject
            - create_context
            - record_event

    SecurityMonitoring:
        when: check_triggered
        validate:
            - verify_check
            - check_rules
            - validate_target
        actions:
            - perform_check
            - analyze_results
            - report_findings
