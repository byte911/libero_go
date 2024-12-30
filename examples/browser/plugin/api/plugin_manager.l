-schema=plugin_manager_api
    version = 1.0

-import
    plugin = "../types/plugin.l"

-api
    PluginManager:
        InstallPlugin:
            input: {
                plugin: plugin.Plugin
            }
            output: {
                instance_id: string,
                error?: string
            }

        EnablePlugin:
            input: {
                instance_id: string
            }
            output: {
                success: bool,
                error?: string
            }

        DisablePlugin:
            input: {
                instance_id: string
            }
            output: {
                success: bool,
                error?: string
            }

        UninstallPlugin:
            input: {
                instance_id: string
            }
            output: {
                success: bool,
                error?: string
            }

        ConfigurePlugin:
            input: {
                instance_id: string,
                config: plugin.PluginConfig
            }
            output: {
                success: bool,
                error?: string
            }

        AddHook:
            input: {
                instance_id: string,
                hook: plugin.PluginHook
            }
            output: {
                hook_id: string,
                error?: string
            }

        InvokeMethod:
            input: {
                instance_id: string,
                method: string,
                params?: object
            }
            output: {
                result?: object,
                error?: string
            }

        EmitEvent:
            input: {
                instance_id: string,
                event: plugin.Event
            }
            output: {
                success: bool,
                error?: string
            }

-rules
    PluginInstallation:
        when: installation_started
        validate:
            - verify_plugin
            - check_dependencies
            - validate_compatibility
        actions:
            - install_plugin
            - setup_resources
            - verify_installation

    PluginExecution:
        when: method_invoked
        validate:
            - verify_instance
            - check_permissions
            - validate_params
        actions:
            - prepare_context
            - execute_method
            - handle_result

    HookManagement:
        when: hook_added
        validate:
            - verify_hook
            - check_priority
            - validate_handler
        actions:
            - register_hook
            - setup_chain
            - verify_registration
