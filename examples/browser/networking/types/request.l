-schema=network_request_types
    version = 1.0

-types
    Request:
        id: string
        url: URL
        method: HttpMethod
        headers: Headers
        body?: RequestBody
        credentials: CredentialsMode
        mode: RequestMode
        priority: RequestPriority
        referrer: ReferrerPolicy
        context: RequestContext
        timing: RequestTiming

    URL:
        scheme: string
        host: string
        port?: int
        path: string
        query: {string: string}
        fragment?: string
        computed:
            is_secure = scheme in ["https", "wss"]
            origin = format("{}://{}", scheme, host)

    HttpMethod:
        enum:
            - GET
            - POST
            - PUT
            - DELETE
            - HEAD
            - OPTIONS
            - PATCH
            - CONNECT
            - TRACE

    Headers:
        entries: {string: string}
        guard: HeadersGuard
        constraints:
            - validate_header_names(entries.keys)
            - validate_header_values(entries.values)

    HeadersGuard:
        enum:
            - NONE
            - REQUEST
            - REQUEST_NO_CORS
            - RESPONSE
            - IMMUTABLE

    RequestBody:
        type: BodyType
        content: string | Blob | FormData | URLSearchParams
        length: int
        encoding?: string

    BodyType:
        enum:
            - TEXT
            - JSON
            - FORM_DATA
            - BLOB
            - ARRAY_BUFFER
            - URL_ENCODED

    CredentialsMode:
        enum:
            - OMIT
            - SAME_ORIGIN
            - INCLUDE

    RequestMode:
        enum:
            - CORS
            - NO_CORS
            - SAME_ORIGIN
            - NAVIGATE

    RequestPriority:
        enum:
            - VERY_LOW
            - LOW
            - NORMAL
            - HIGH
            - VERY_HIGH
        computed:
            weight = match this:
                VERY_LOW -> 1
                LOW -> 2
                NORMAL -> 3
                HIGH -> 4
                VERY_HIGH -> 5

    ReferrerPolicy:
        enum:
            - NO_REFERRER
            - NO_REFERRER_WHEN_DOWNGRADE
            - ORIGIN
            - ORIGIN_WHEN_CROSS_ORIGIN
            - SAME_ORIGIN
            - STRICT_ORIGIN
            - STRICT_ORIGIN_WHEN_CROSS_ORIGIN
            - UNSAFE_URL

    RequestContext:
        type: RequestContextType
        initiator: RequestInitiator
        destination: RequestDestination
        render_blocking: bool
        keep_alive: bool

    RequestContextType:
        enum:
            - DOCUMENT
            - STYLESHEET
            - IMAGE
            - MEDIA
            - FONT
            - SCRIPT
            - XHR
            - FETCH
            - WEBSOCKET
            - MANIFEST
            - SIGNED_EXCHANGE

    RequestInitiator:
        type: string  # document, script, user
        url: string
        line?: int
        column?: int

    RequestDestination:
        enum:
            - EMPTY
            - DOCUMENT
            - IFRAME
            - IMAGE
            - STYLE
            - SCRIPT
            - WORKER
            - AUDIO
            - VIDEO
            - FONT

    RequestTiming:
        start_time: timestamp
        dns_start?: timestamp
        dns_end?: timestamp
        connect_start?: timestamp
        connect_end?: timestamp
        tls_start?: timestamp
        tls_end?: timestamp
        send_start?: timestamp
        send_end?: timestamp
        receive_start?: timestamp
        receive_end?: timestamp
        computed:
            total_time = receive_end - start_time
            dns_time = dns_end - dns_start
            connect_time = connect_end - connect_start
            tls_time = tls_end - tls_start
            send_time = send_end - send_start
            receive_time = receive_end - receive_start
