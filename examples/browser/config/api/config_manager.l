-schema=config_manager_api
    version = 1.0

-import
    config = "../types/config.l"

-api
    ConfigManager:
        CreateConfig:
            input: {
                name: string,
                sections: [config.ConfigSection],
                metadata?: object
            }
            output: {
                config_id: string,
                error?: string
            }

        GetConfig:
            input: {
                config_id: string,
                version?: string
            }
            output: {
                config?: config.Config,
                error?: string
            }

        UpdateConfig:
            input: {
                config_id: string,
                changes: [config.ChangeItem],
                reason?: string
            }
            output: {
                success: bool,
                validation?: config.ConfigValidation,
                error?: string
            }

        ValidateConfig:
            input: {
                config: config.Config,
                rules?: [config.ValidationRule]
            }
            output: {
                validation?: config.ConfigValidation,
                error?: string
            }

        CreateSnapshot:
            input: {
                config_id: string,
                metadata?: object
            }
            output: {
                snapshot_id: string,
                error?: string
            }

        ApplyTemplate:
            input: {
                template: config.ConfigTemplate,
                variables: object
            }
            output: {
                config?: config.Config,
                error?: string
            }

        GetHistory:
            input: {
                config_id: string,
                timerange: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                changes: [config.ConfigChange],
                error?: string
            }

        GenerateReport:
            input: {
                config_id: string,
                options?: {
                    include_changes?: bool,
                    include_validations?: bool
                }
            }
            output: {
                report?: config.ConfigReport,
                error?: string
            }

-rules
    ConfigManagement:
        when: config_operation
        validate:
            - verify_permissions
            - check_schema
            - validate_dependencies
        actions:
            - execute_operation
            - record_change
            - notify_subscribers

    ValidationExecution:
        when: validation_requested
        validate:
            - verify_rules
            - check_values
            - validate_types
        actions:
            - run_validation
            - collect_issues
            - update_status

    TemplateProcessing:
        when: template_applied
        validate:
            - verify_template
            - check_variables
            - validate_substitution
        actions:
            - process_template
            - validate_result
            - create_config
