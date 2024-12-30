-schema=api_types
    version = 1.0

-types
    API:
        id: string
        name: string
        version: string
        description?: string
        endpoints: [Endpoint]
        config: APIConfig

    Endpoint:
        id: string
        path: string
        method: HTTPMethod
        handlers: [Handler]
        config: EndpointConfig

    HTTPMethod:
        enum:
            - GET
            - POST
            - PUT
            - DELETE
            - PATCH

    Handler:
        id: string
        type: HandlerType
        middleware: [Middleware]
        config: HandlerConfig

    HandlerType:
        enum:
            - REQUEST
            - RESPONSE
            - ERROR
            - VALIDATION

    Middleware:
        id: string
        type: MiddlewareType
        config: object
        priority: int

    MiddlewareType:
        enum:
            - AUTH
            - CACHE
            - LOG
            - RATE_LIMIT

    APIConfig:
        version: string
        base_path: string
        timeout: int
        rate_limit?: RateLimit

    EndpointConfig:
        timeout?: int
        rate_limit?: RateLimit
        cache?: CacheConfig
        validation?: ValidationConfig

    HandlerConfig:
        timeout?: int
        retry?: RetryConfig
        circuit_breaker?: CircuitConfig

    RateLimit:
        requests: int
        window: int
        by?: string

    CacheConfig:
        ttl: int
        strategy: string
        key_pattern: string

    ValidationConfig:
        schema: object
        rules: [ValidationRule]

    ValidationRule:
        field: string
        type: string
        rules: [string]

    RetryConfig:
        max_attempts: int
        backoff: float
        timeout: int

    CircuitConfig:
        threshold: float
        timeout: int
        half_open: int

    APIRequest:
        id: string
        endpoint: string
        method: HTTPMethod
        headers: object
        params: object
        body?: object

    APIResponse:
        id: string
        request_id: string
        status: int
        headers: object
        body?: object

    APIMetrics:
        requests: int
        latency: {
            avg: float,
            p95: float,
            p99: float
        }
        errors: {
            count: int,
            rate: float
        }

    APIReport:
        id: string
        timestamp: timestamp
        duration: int
        metrics: APIMetrics
        endpoints: [EndpointMetrics]
        errors: [APIError]

    EndpointMetrics:
        endpoint: string
        requests: int
        success_rate: float
        latency: object

    APIError:
        id: string
        timestamp: timestamp
        endpoint: string
        type: string
        message: string
        stack?: string
