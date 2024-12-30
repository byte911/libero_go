-schema=http_protocol
    version = 1.0

-import
    request = "../types/request.l"
    response = "../types/response.l"

-api
    HttpProtocol:
        # 发送请求
        SendRequest:
            input: {
                request: request.Request,
                options: {
                    timeout: int,
                    retry_config: RetryConfig,
                    compression: bool,
                    pipeline: bool
                }
            }
            output: {
                response: response.Response,
                metrics: RequestMetrics
            }

        # 取消请求
        CancelRequest:
            input: {
                request_id: string,
                reason: string
            }
            output: {
                success: bool,
                error?: string
            }

        # 请求复用
        ReuseConnection:
            input: {
                host: string,
                options: {
                    max_requests: int,
                    idle_timeout: int,
                    validate: bool
                }
            }
            output: {
                connection_id: string,
                status: ConnectionStatus
            }

        # HTTP/2 推送
        HandlePush:
            input: {
                stream_id: string,
                headers: Headers,
                promised_request: request.Request
            }
            output: {
                accepted: bool,
                reason?: string
            }

-types
    RetryConfig:
        max_retries: int
        delay_ms: int
        backoff_factor: float
        retry_conditions: [RetryCondition]

    RetryCondition:
        enum:
            - TIMEOUT
            - CONNECTION_ERROR
            - SERVER_ERROR
            - RATE_LIMIT
            - NETWORK_ERROR

    RequestMetrics:
        timing: {
            dns_lookup: int,
            tcp_connection: int,
            tls_handshake: int,
            first_byte: int,
            download: int,
            total: int
        }
        size: {
            headers: int,
            body: int,
            total: int
        }
        protocol: string
        cached: bool
        compressed: bool

    ConnectionStatus:
        active: bool
        protocol: string
        requests_served: int
        idle_time: int
        created_at: timestamp
        last_used: timestamp

    Headers:
        entries: {string: string}
        computed:
            content_length = int(entries["content-length"])
            content_type = entries["content-type"]
            is_chunked = entries["transfer-encoding"] == "chunked"

-rules
    RequestValidation:
        when: before_send_request
        validate:
            - request.url is_valid
            - request.method in allowed_methods
            - validate_headers(request.headers)
            - validate_body_size(request.body)
        actions:
            - normalize_headers
            - apply_default_headers
            - compress_if_needed

    ResponseValidation:
        when: after_receive_response
        validate:
            - response.status between 100 and 599
            - validate_headers(response.headers)
            - check_content_length
        actions:
            - decompress_if_needed
            - parse_body
            - update_cache

    CacheControl:
        when: before_cache_store
        validate:
            - response.cacheable
            - not response.private
            - validate_freshness
        actions:
            - store_in_cache
            - update_metadata
            - cleanup_if_needed

    SecurityChecks:
        when: before_send_request
        validate:
            - verify_https_upgrade
            - check_mixed_content
            - validate_certificates
        actions:
            - upgrade_to_https
            - log_security_warning
