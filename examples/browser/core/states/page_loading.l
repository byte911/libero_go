-schema=page_loading_states
    version = 1.0

-states
    PageLoading:
        initial: initial
        states:
            initial:
                description: "初始状态"
            dns_lookup:
                description: "DNS解析"
            connecting:
                description: "建立连接"
            sending_request:
                description: "发送请求"
            receiving_response:
                description: "接收响应"
            parsing_html:
                description: "解析HTML"
            loading_resources:
                description: "加载资源"
            executing_scripts:
                description: "执行脚本"
            rendering:
                description: "渲染页面"
            complete:
                description: "加载完成"
            error:
                description: "加载错误"

        transitions:
            initial -> dns_lookup:
                when: url_submitted
                actions: [create_page_context, start_dns_lookup]

            dns_lookup -> connecting:
                when: dns_resolved
                actions: [create_connection]

            dns_lookup -> error:
                when: dns_error
                actions: [log_error, show_dns_error]

            connecting -> sending_request:
                when: connection_established
                actions: [prepare_http_request]

            connecting -> error:
                when: connection_error
                actions: [log_error, show_connection_error]

            sending_request -> receiving_response:
                when: request_sent
                actions: [start_response_timer]

            sending_request -> error:
                when: request_error
                actions: [log_error, show_request_error]

            receiving_response -> parsing_html:
                when: response_complete
                actions: [
                    validate_response,
                    create_document,
                    start_html_parser
                ]

            receiving_response -> error:
                when: response_error or response_timeout
                actions: [log_error, show_response_error]

            parsing_html -> loading_resources:
                when: dom_constructed
                actions: [
                    collect_resources,
                    prioritize_resources,
                    start_resource_loader
                ]

            parsing_html -> error:
                when: parsing_error
                actions: [log_error, show_parsing_error]

            loading_resources -> executing_scripts:
                when: critical_resources_loaded
                actions: [
                    prepare_script_context,
                    schedule_script_execution
                ]

            loading_resources -> error:
                when: resource_error
                actions: [
                    log_error,
                    show_resource_error,
                    continue_with_available_resources
                ]

            executing_scripts -> rendering:
                when: scripts_executed
                actions: [
                    compute_styles,
                    build_render_tree,
                    layout_calculation,
                    start_painting
                ]

            executing_scripts -> error:
                when: script_error
                actions: [
                    log_error,
                    show_script_error,
                    attempt_recovery
                ]

            rendering -> complete:
                when: painting_complete
                actions: [
                    mark_page_ready,
                    trigger_load_event,
                    start_post_load_tasks
                ]

            rendering -> error:
                when: rendering_error
                actions: [
                    log_error,
                    show_rendering_error,
                    attempt_recovery
                ]

        error_handlers:
            network_error:
                actions: [
                    retry_connection,
                    update_error_ui,
                    collect_diagnostics
                ]

            resource_error:
                actions: [
                    skip_failed_resource,
                    mark_as_degraded,
                    continue_loading
                ]

            script_error:
                actions: [
                    disable_failing_script,
                    log_to_console,
                    continue_execution
                ]
