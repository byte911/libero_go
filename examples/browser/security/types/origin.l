-schema=security_origin_types
    version = 1.0

-types
    Origin:
        scheme: string
        host: string
        port: int
        computed:
            is_secure = scheme in ["https", "wss"]
            standard_port = match scheme:
                "http" -> 80
                "https" -> 443
                "ws" -> 80
                "wss" -> 443
                otherwise -> port
            serialized = format("{}://{}:{}", scheme, host, port)

    SecurityContext:
        origin: Origin
        nonce: string
        permissions: [Permission]
        sandbox_flags: SandboxFlags
        csp_context: CSPContext
        isolation_state: IsolationState

    Permission:
        name: string
        state: PermissionState
        expiry?: timestamp
        constraints: [string]

    PermissionState:
        enum:
            - GRANTED
            - DENIED
            - PROMPT

    SandboxFlags:
        allow_scripts: bool
        allow_same_origin: bool
        allow_top_navigation: bool
        allow_popups: bool
        allow_forms: bool
        allow_pointer_lock: bool
        allow_presentation: bool
        allow_modals: bool
        allow_downloads: bool

    IsolationState:
        process_id: int
        site_isolation: bool
        cross_origin_isolated: bool
        direct_socket_access: bool
        shared_array_buffer_enabled: bool
