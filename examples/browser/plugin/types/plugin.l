-schema=plugin_types
    version = 1.0

-types
    Plugin:
        id: string
        name: string
        version: string
        type: PluginType
        interfaces: [Interface]
        dependencies: [Dependency]
        config: PluginConfig

    PluginType:
        enum:
            - CORE
            - EXTENSION
            - THEME
            - TOOL

    Interface:
        id: string
        name: string
        version: string
        methods: [Method]
        events: [Event]

    Method:
        name: string
        input: object
        output: object
        async: bool

    Event:
        name: string
        data: object
        async: bool

    Dependency:
        id: string
        name: string
        version: string
        optional: bool

    PluginConfig:
        enabled: bool
        auto_start: bool
        priority: int
        settings: object

    PluginInstance:
        id: string
        plugin_id: string
        status: PluginStatus
        context: object
        state: object

    PluginStatus:
        enum:
            - INSTALLED
            - ENABLED
            - DISABLED
            - ERROR

    PluginLifecycle:
        install: string
        enable: string
        disable: string
        uninstall: string

    PluginHook:
        id: string
        type: HookType
        priority: int
        handler: string

    HookType:
        enum:
            - PRE
            - POST
            - ERROR

    PluginMetadata:
        author: string
        description: string
        homepage?: string
        repository?: string
        license?: string

    PluginResource:
        id: string
        type: string
        path: string
        content?: object

    PluginPermission:
        id: string
        resource: string
        action: string
        condition?: object

    PluginMetrics:
        usage: {
            calls: int,
            errors: int
        }
        performance: {
            latency: float,
            memory: float
        }

    PluginReport:
        id: string
        timestamp: timestamp
        plugin_id: string
        metrics: PluginMetrics
        events: [PluginEvent]

    PluginEvent:
        id: string
        type: string
        timestamp: timestamp
        data: object
