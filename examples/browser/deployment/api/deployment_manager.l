-schema=deployment_manager_api
    version = 1.0

-import
    deployment = "../types/deployment.l"

-api
    DeploymentManager:
        CreateDeployment:
            input: {
                deployment: deployment.Deployment
            }
            output: {
                deployment_id: string,
                error?: string
            }

        StartDeployment:
            input: {
                deployment_id: string
            }
            output: {
                status?: deployment.DeploymentStatus,
                error?: string
            }

        GetStatus:
            input: {
                deployment_id: string
            }
            output: {
                status?: deployment.DeploymentStatus,
                error?: string
            }

        UpdateComponent:
            input: {
                deployment_id: string,
                component: deployment.Component
            }
            output: {
                success: bool,
                error?: string
            }

        ScaleComponent:
            input: {
                deployment_id: string,
                component_id: string,
                replicas: int
            }
            output: {
                success: bool,
                error?: string
            }

        RollbackDeployment:
            input: {
                deployment_id: string,
                version?: string
            }
            output: {
                success: bool,
                error?: string
            }

        MonitorDeployment:
            input: {
                deployment_id: string,
                metrics: [string]
            }
            output: {
                metrics: object,
                error?: string
            }

        GenerateReport:
            input: {
                deployment_id: string,
                timerange: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                report?: deployment.DeploymentReport,
                error?: string
            }

-rules
    DeploymentExecution:
        when: deployment_started
        validate:
            - verify_deployment
            - check_dependencies
            - validate_resources
        actions:
            - prepare_environment
            - deploy_components
            - verify_health

    ComponentManagement:
        when: component_updated
        validate:
            - verify_component
            - check_version
            - validate_config
        actions:
            - update_component
            - verify_update
            - sync_state

    ScalingManagement:
        when: scaling_requested
        validate:
            - verify_component
            - check_resources
            - validate_limits
        actions:
            - scale_component
            - verify_scaling
            - update_status
