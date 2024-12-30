-schema=network_response_types
    version = 1.0

-types
    Response:
        request_id: string
        url: string
        status: int
        status_text: string
        headers: Headers
        body?: ResponseBody
        timing: ResponseTiming
        security: SecurityInfo
        cache_state: CacheState
        source: ResponseSource

    ResponseBody:
        type: BodyType
        content: string | Blob | FormData | ArrayBuffer
        length: int
        encoding?: string
        complete: bool
        corrupted: bool

    ResponseTiming:
        request_time: timestamp
        response_start: timestamp
        download_start: timestamp
        download_end: timestamp
        computed:
            ttfb = response_start - request_time
            download_time = download_end - download_start
            total_time = download_end - request_time

    SecurityInfo:
        protocol: string
        cipher: string
        cert_issuer: string
        cert_subject: string
        cert_valid_from: timestamp
        cert_valid_to: timestamp
        cert_serial: string
        cert_fingerprint: string
        computed:
            is_secure = protocol starts_with "TLS"
            is_valid = now() between cert_valid_from and cert_valid_to

    CacheState:
        cached: bool
        validated: bool
        validation_time?: timestamp
        age: int
        expires?: timestamp
        etag?: string
        last_modified?: timestamp
        computed:
            is_fresh = match this:
                when not cached -> false
                when age > max_age -> false
                when expires exists and now() > expires -> false
                otherwise -> true

    ResponseSource:
        enum:
            - NETWORK
            - CACHE
            - SERVICE_WORKER
            - PREFETCH
            - PRELOAD

    Headers:
        entries: {string: string}
        guard: HeadersGuard
        computed:
            content_type = entries["content-type"]
            content_length = int(entries["content-length"])
            is_chunked = entries["transfer-encoding"] == "chunked"
            is_gzipped = entries["content-encoding"] == "gzip"

    HeadersGuard:
        enum:
            - NONE
            - RESPONSE
            - IMMUTABLE

    BodyType:
        enum:
            - TEXT
            - JSON
            - HTML
            - XML
            - FORM_DATA
            - BLOB
            - ARRAY_BUFFER
            - STREAM
