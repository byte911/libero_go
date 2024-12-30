-schema=config_validator_api
    version = 1.0

-import
    config = "../types/config.l"

-api
    ConfigValidator:
        ValidateSchema:
            input: {
                config: config.Config,
                schema: object
            }
            output: {
                valid: bool,
                issues: [config.ValidationIssue],
                error?: string
            }

        ValidateValues:
            input: {
                items: [config.ConfigItem],
                rules: [config.ValidationRule]
            }
            output: {
                valid: bool,
                issues: [config.ValidationIssue],
                error?: string
            }

        ValidateDependencies:
            input: {
                sections: [config.ConfigSection],
                context?: object
            }
            output: {
                valid: bool,
                issues: [config.ValidationIssue],
                error?: string
            }

        ValidateTemplate:
            input: {
                template: config.ConfigTemplate,
                variables: object
            }
            output: {
                valid: bool,
                issues: [config.ValidationIssue],
                error?: string
            }

        ValidateChanges:
            input: {
                changes: [config.ChangeItem],
                current: config.Config
            }
            output: {
                valid: bool,
                issues: [config.ValidationIssue],
                error?: string
            }

        CustomValidation:
            input: {
                config: config.Config,
                validator: string,
                params?: object
            }
            output: {
                valid: bool,
                issues: [config.ValidationIssue],
                error?: string
            }

-rules
    SchemaValidation:
        when: schema_validation
        validate:
            - verify_schema
            - check_types
            - validate_structure
        actions:
            - validate_schema
            - collect_issues
            - generate_report

    ValueValidation:
        when: value_validation
        validate:
            - verify_rules
            - check_values
            - validate_constraints
        actions:
            - validate_values
            - check_types
            - report_issues

    DependencyValidation:
        when: dependency_validation
        validate:
            - verify_dependencies
            - check_circular
            - validate_references
        actions:
            - resolve_dependencies
            - validate_graph
            - report_conflicts
