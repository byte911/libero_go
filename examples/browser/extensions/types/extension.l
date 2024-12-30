-schema=extension_types
    version = 1.0

-import
    origin = "../../security/types/origin.l"
    permission = "../../security/states/permission.l"

-types
    Extension:
        id: string
        manifest: Manifest
        state: ExtensionState
        permissions: [permission.PermissionState]
        origins: [origin.Origin]
        resources: [Resource]

    Manifest:
        name: string
        version: string
        description?: string
        author?: string
        homepage_url?: string
        icons: {string: string}  # size -> path
        permissions: [string]
        host_permissions: [string]
        background?: Background
        content_scripts?: [ContentScript]
        web_accessible_resources?: [Resource]
        options_page?: string
        action?: Action
        commands?: {string: Command}

    Background:
        service_worker?: string
        type?: string  # module or classic
        persistent?: bool

    ContentScript:
        matches: [string]
        exclude_matches?: [string]
        js?: [string]
        css?: [string]
        run_at?: RunAt
        all_frames?: bool
        match_about_blank?: bool
        world?: string

    RunAt:
        enum:
            - DOCUMENT_START
            - DOCUMENT_END
            - DOCUMENT_IDLE

    Resource:
        path: string
        mime_type: string
        access: ResourceAccess

    ResourceAccess:
        matches: [string]
        extension_ids?: [string]

    Action:
        default_icon?: {string: string}
        default_title?: string
        default_popup?: string

    Command:
        suggested_key?: {
            default?: string,
            mac?: string,
            windows?: string,
            linux?: string,
            chromeos?: string
        }
        description?: string

    ExtensionState:
        enum:
            - INSTALLED
            - ENABLED
            - DISABLED
            - BLOCKED
            - CRASHED
            - UPDATING
