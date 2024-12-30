-schema=extension_messaging_types
    version = 1.0

-types
    Message:
        id: string
        type: MessageType
        source: MessageEndpoint
        target: MessageEndpoint
        content: any
        timestamp: timestamp

    MessageType:
        enum:
            - REQUEST
            - RESPONSE
            - EVENT
            - ERROR

    MessageEndpoint:
        type: EndpointType
        extension_id?: string
        tab_id?: int
        frame_id?: int
        worker_id?: string

    EndpointType:
        enum:
            - EXTENSION
            - CONTENT_SCRIPT
            - BACKGROUND_WORKER
            - POPUP
            - OPTIONS_PAGE
            - NATIVE_APP

    Port:
        id: string
        name: string
        source: MessageEndpoint
        target: MessageEndpoint
        state: PortState

    PortState:
        enum:
            - CONNECTING
            - CONNECTED
            - DISCONNECTED
            - ERROR

    MessageFilter:
        types?: [MessageType]
        sources?: [MessageEndpoint]
        targets?: [MessageEndpoint]
        pattern?: string

    MessageQueue:
        id: string
        filters: [MessageFilter]
        max_size: int
        messages: [Message]

    NativeMessaging:
        app_name: string
        allowed_origins: [string]
        description: string
        path: string
        type: string
