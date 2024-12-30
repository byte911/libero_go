-schema=resource_manager_api
    version = 1.0

-import
    resource = "../types/resource.l"

-api
    ResourceManager:
        CreatePool:
            input: {
                resources: [resource.Resource],
                policy: resource.AllocationPolicy
            }
            output: {
                pool_id: string,
                error?: string
            }

        RequestResource:
            input: {
                request: resource.ResourceRequest
            }
            output: {
                allocation?: resource.ResourceAllocation,
                error?: string
            }

        ReleaseResource:
            input: {
                allocation_id: string
            }
            output: {
                success: bool,
                error?: string
            }

        UpdateLimits:
            input: {
                resource_id: string,
                limits: resource.ResourceLimits
            }
            output: {
                success: bool,
                error?: string
            }

        GetResourceStatus:
            input: {
                resource_id: string
            }
            output: {
                state?: resource.ResourceState,
                error?: string
            }

        GetPoolStatus:
            input: {
                pool_id: string
            }
            output: {
                status?: resource.PoolStatus,
                error?: string
            }

        MonitorResources:
            input: {
                pool_id: string,
                metrics: [string]
            }
            output: {
                metrics?: resource.ResourceMetrics,
                error?: string
            }

        GenerateReport:
            input: {
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                pools: [string]
            }
            output: {
                report?: resource.ResourceReport,
                error?: string
            }

-rules
    ResourceAllocation:
        when: resource_requested
        validate:
            - verify_request
            - check_availability
            - validate_constraints
        actions:
            - allocate_resource
            - update_metrics
            - notify_allocation

    ResourceRelease:
        when: resource_released
        validate:
            - verify_allocation
            - check_state
            - validate_release
        actions:
            - release_resource
            - update_pool
            - notify_release

    MetricsCollection:
        when: metrics_requested
        validate:
            - verify_metrics
            - check_access
            - validate_timerange
        actions:
            - collect_metrics
            - calculate_stats
            - generate_report
