-schema=api_gateway_api
    version = 1.0

-import
    api = "../types/api.l"

-api
    APIGateway:
        RouteRequest:
            input: {
                request: api.APIRequest
            }
            output: {
                route?: object,
                error?: string
            }

        LoadBalance:
            input: {
                request: api.APIRequest,
                endpoints: [string]
            }
            output: {
                endpoint?: string,
                error?: string
            }

        ApplyMiddleware:
            input: {
                request: api.APIRequest,
                middleware: [api.Middleware]
            }
            output: {
                modified_request?: api.APIRequest,
                error?: string
            }

        CacheResponse:
            input: {
                request: api.APIRequest,
                response: api.APIResponse,
                config: api.CacheConfig
            }
            output: {
                success: bool,
                error?: string
            }

        RateLimit:
            input: {
                request: api.APIRequest,
                config: api.RateLimit
            }
            output: {
                allowed: bool,
                wait_time?: int
            }

        CircuitBreak:
            input: {
                endpoint: string,
                config: api.CircuitConfig
            }
            output: {
                state: string,
                error?: string
            }

        TransformRequest:
            input: {
                request: api.APIRequest,
                transforms: [object]
            }
            output: {
                transformed?: api.APIRequest,
                error?: string
            }

        TransformResponse:
            input: {
                response: api.APIResponse,
                transforms: [object]
            }
            output: {
                transformed?: api.APIResponse,
                error?: string
            }

-rules
    RequestRouting:
        when: request_received
        validate:
            - verify_request
            - check_route
            - validate_endpoint
        actions:
            - route_request
            - apply_middleware
            - forward_request

    LoadBalancing:
        when: routing_needed
        validate:
            - verify_endpoints
            - check_health
            - validate_capacity
        actions:
            - select_endpoint
            - update_metrics
            - route_request

    CacheManagement:
        when: cache_requested
        validate:
            - verify_request
            - check_policy
            - validate_key
        actions:
            - check_cache
            - store_response
            - update_stats
