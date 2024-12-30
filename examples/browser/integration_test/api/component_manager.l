-schema=component_manager_api
    version = 1.0

-import
    integration = "../types/integration_test.l"

-api
    ComponentManager:
        RegisterComponent:
            input: {
                component: integration.Component
            }
            output: {
                success: bool,
                error?: string
            }

        ConfigureComponent:
            input: {
                name: string,
                config: object
            }
            output: {
                success: bool,
                error?: string
            }

        CheckDependencies:
            input: {
                component: string
            }
            output: {
                satisfied: bool,
                missing: [string],
                error?: string
            }

        GetComponentStatus:
            input: {
                name: string
            }
            output: {
                status?: integration.ComponentStatus,
                metrics?: object,
                error?: string
            }

        ExecuteAction:
            input: {
                component: string,
                action: integration.Action
            }
            output: {
                result?: any,
                error?: string
            }

        MonitorEvents:
            input: {
                component: string,
                event_types: [string]
            }
            output: {
                events: [object],
                error?: string
            }

        CollectMetrics:
            input: {
                component: string,
                metrics: [string]
            }
            output: {
                values: object,
                error?: string
            }

        ValidateState:
            input: {
                component: string,
                expected_state: object
            }
            output: {
                valid: bool,
                differences: [string],
                error?: string
            }

-rules
    ComponentRegistration:
        when: component_registered
        validate:
            - verify_component_spec
            - check_name_conflicts
            - validate_config
        actions:
            - register_component
            - setup_monitoring
            - notify_registration

    DependencyManagement:
        when: dependency_check
        validate:
            - verify_dependency_graph
            - check_circular_deps
            - validate_versions
        actions:
            - resolve_dependencies
            - update_status
            - notify_changes

    StateValidation:
        when: state_validation
        validate:
            - verify_state_schema
            - check_constraints
            - validate_transitions
        actions:
            - compare_states
            - record_differences
            - notify_validation
