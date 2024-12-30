-schema=content_security_policy
    version = 1.0

-types
    CSPContext:
        policies: [CSPPolicy]
        reporting_endpoints: [string]
        violation_reports: [CSPViolation]
        enforcement_mode: CSPMode

    CSPPolicy:
        directives: {string: CSPDirective}
        report_only: bool
        source: string  # header or meta tag

    CSPDirective:
        name: string
        values: [CSPSource]
        fallback: CSPFallback

    CSPSource:
        type: SourceType
        value: string
        schemes?: [string]
        ports?: [string]
        paths?: [string]
        nonce?: string
        hash?: string

    SourceType:
        enum:
            - SELF
            - SCHEME
            - HOST
            - NONCE
            - HASH
            - UNSAFE_INLINE
            - UNSAFE_EVAL
            - STRICT_DYNAMIC
            - NONE

    CSPFallback:
        enum:
            - ALLOW
            - DENY
            - REPORT

    CSPMode:
        enum:
            - ENFORCE
            - REPORT_ONLY
            - MIXED

    CSPViolation:
        policy: string
        directive: string
        blocked_uri: string
        document_uri: string
        original_policy: string
        referrer: string
        violated_directive: string
        source_file?: string
        line_number?: int
        column_number?: int
        status_code?: int

-api
    CSPEnforcer:
        ValidateResource:
            input: {
                resource_url: string,
                resource_type: string,
                context: {
                    document_url: string,
                    nonce?: string,
                    hash?: string
                }
            }
            output: {
                allowed: bool,
                violated_directive?: string,
                report?: CSPViolation
            }

        ReportViolation:
            input: CSPViolation
            output: {
                report_id: string,
                sent_to: [string]
            }

        UpdatePolicy:
            input: {
                policy: CSPPolicy,
                mode: CSPMode
            }
            output: {
                success: bool,
                errors: [string]
            }

-rules
    ResourceValidation:
        when: before_resource_load
        validate:
            - check_source_allowed(resource.url, policy.directives)
            - validate_nonce_if_present(resource.nonce)
            - validate_hash_if_present(resource.hash)
        actions:
            - block_if_violation
            - report_if_configured
            - log_decision

    InlineScriptValidation:
        when: before_script_execution
        validate:
            - check_unsafe_inline_allowed
            - validate_script_nonce
            - validate_script_hash
        actions:
            - block_if_violation
            - report_if_configured
            - log_decision

    EvalValidation:
        when: before_eval_execution
        validate:
            - check_unsafe_eval_allowed
        actions:
            - block_if_violation
            - report_if_configured
            - log_decision
