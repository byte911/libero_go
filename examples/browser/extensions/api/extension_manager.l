-schema=extension_manager_api
    version = 1.0

-import
    extension = "../types/extension.l"
    messaging = "../types/messaging.l"

-api
    ExtensionManager:
        Install:
            input: {
                source: string,  # URL or local path
                options?: {
                    allow_file_access?: bool,
                    grant_permissions?: bool
                }
            }
            output: {
                extension?: extension.Extension,
                error?: string
            }

        Uninstall:
            input: {
                id: string,
                options?: {
                    keep_data?: bool
                }
            }
            output: {
                success: bool,
                error?: string
            }

        Enable:
            input: {
                id: string,
                temporary?: bool
            }
            output: {
                success: bool,
                error?: string
            }

        Disable:
            input: {
                id: string,
                reason?: string
            }
            output: {
                success: bool,
                error?: string
            }

        Update:
            input: {
                id: string,
                options?: {
                    immediate?: bool,
                    reload?: bool
                }
            }
            output: {
                success: bool,
                version?: string,
                error?: string
            }

        GetExtension:
            input: {
                id: string
            }
            output: {
                extension?: extension.Extension,
                error?: string
            }

        ListExtensions:
            input: {
                state?: extension.ExtensionState,
                includes_disabled?: bool
            }
            output: {
                extensions: extension.Extension[],
                error?: string
            }

        GetPermissions:
            input: {
                id: string
            }
            output: {
                permissions: [string],
                origins: [string],
                error?: string
            }

        RequestPermissions:
            input: {
                id: string,
                permissions: [string],
                origins: [string]
            }
            output: {
                granted: bool,
                error?: string
            }

-rules
    InstallValidation:
        when: before_install
        validate:
            - verify_manifest
            - check_permissions
            - validate_resources
            - scan_for_malware
        actions:
            - create_extension_directory
            - extract_resources
            - register_extension

    UpdateCheck:
        when: update_requested
        validate:
            - check_version_compatibility
            - verify_signature
            - validate_changes
        actions:
            - download_update
            - backup_current_version
            - apply_update

    PermissionControl:
        when: permission_requested
        validate:
            - verify_permission_scope
            - check_host_permissions
            - validate_api_access
        actions:
            - prompt_user
            - update_permissions
            - notify_extension
