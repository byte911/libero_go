-schema=plugin_registry_api
    version = 1.0

-import
    plugin = "../types/plugin.l"

-api
    PluginRegistry:
        RegisterPlugin:
            input: {
                metadata: plugin.PluginMetadata,
                interfaces: [plugin.Interface]
            }
            output: {
                plugin_id: string,
                error?: string
            }

        DiscoverPlugins:
            input: {
                criteria?: object
            }
            output: {
                plugins: [plugin.Plugin],
                error?: string
            }

        ValidatePlugin:
            input: {
                plugin: plugin.Plugin
            }
            output: {
                valid: bool,
                issues?: [string]
            }

        ResolveConflicts:
            input: {
                plugins: [plugin.Plugin]
            }
            output: {
                resolution?: object,
                error?: string
            }

        TrackUsage:
            input: {
                plugin_id: string,
                metrics: plugin.PluginMetrics
            }
            output: {
                success: bool,
                error?: string
            }

        GenerateReport:
            input: {
                plugin_id: string,
                timerange: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                report?: plugin.PluginReport,
                error?: string
            }

-rules
    PluginRegistration:
        when: registration_started
        validate:
            - verify_metadata
            - check_interfaces
            - validate_version
        actions:
            - register_plugin
            - index_interfaces
            - notify_registry

    PluginDiscovery:
        when: discovery_started
        validate:
            - verify_criteria
            - check_sources
            - validate_access
        actions:
            - search_plugins
            - filter_results
            - sort_plugins

    ConflictResolution:
        when: conflict_detected
        validate:
            - verify_plugins
            - check_dependencies
            - validate_compatibility
        actions:
            - analyze_conflicts
            - resolve_issues
            - update_registry
