-schema=network_connection_states
    version = 1.0

-states
    Connection:
        initial: idle
        states:
            idle:
                description: "连接空闲"
            dns_resolving:
                description: "DNS解析中"
            connecting:
                description: "建立TCP连接"
            tls_handshaking:
                description: "TLS握手"
            established:
                description: "连接已建立"
            active:
                description: "数据传输中"
            closing:
                description: "关闭连接"
            closed:
                description: "连接已关闭"
            error:
                description: "连接错误"

        transitions:
            idle -> dns_resolving:
                when: connection_requested
                actions: [
                    record_start_time,
                    start_dns_resolution
                ]

            dns_resolving -> connecting:
                when: dns_resolved
                actions: [
                    record_dns_time,
                    create_socket
                ]

            dns_resolving -> error:
                when: dns_error
                actions: [
                    log_error,
                    notify_failure,
                    cleanup_resources
                ]

            connecting -> tls_handshaking:
                when: connection_established and requires_tls
                actions: [
                    record_connect_time,
                    start_tls_handshake
                ]

            connecting -> established:
                when: connection_established and not requires_tls
                actions: [
                    record_connect_time,
                    setup_keepalive
                ]

            connecting -> error:
                when: connection_failed
                actions: [
                    log_error,
                    notify_failure,
                    cleanup_resources
                ]

            tls_handshaking -> established:
                when: tls_complete
                actions: [
                    record_tls_time,
                    verify_certificate,
                    setup_secure_context
                ]

            tls_handshaking -> error:
                when: tls_error
                actions: [
                    log_error,
                    notify_security_failure,
                    cleanup_resources
                ]

            established -> active:
                when: data_requested
                actions: [
                    prepare_buffers,
                    start_transfer_tracking
                ]

            active -> established:
                when: transfer_complete
                actions: [
                    record_transfer_stats,
                    reset_buffers
                ]

            active -> error:
                when: transfer_error
                actions: [
                    log_error,
                    notify_failure,
                    attempt_recovery
                ]

            established -> closing:
                when: close_requested
                actions: [
                    flush_buffers,
                    start_graceful_shutdown
                ]

            closing -> closed:
                when: shutdown_complete
                actions: [
                    record_final_stats,
                    cleanup_resources
                ]

            error -> idle:
                when: retry_requested and can_retry
                actions: [
                    reset_state,
                    increment_retry_count
                ]

        error_handlers:
            connection_timeout:
                actions: [
                    log_timeout,
                    cleanup_resources,
                    notify_timeout
                ]

            security_error:
                actions: [
                    log_security_error,
                    notify_security_failure,
                    blacklist_if_needed
                ]

            network_error:
                actions: [
                    log_network_error,
                    attempt_reconnect,
                    notify_if_fatal
                ]
