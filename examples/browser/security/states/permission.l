-schema=permission_states
    version = 1.0

-states
    PermissionState:
        initial: unknown
        states:
            unknown:
                description: "权限状态未知"
            prompt_needed:
                description: "需要用户授权"
            checking:
                description: "检查权限中"
            granted:
                description: "已授权"
            denied:
                description: "已拒绝"
            revoked:
                description: "权限已撤销"
            error:
                description: "权限错误"

        transitions:
            unknown -> checking:
                when: permission_requested
                actions: [
                    load_permission_cache,
                    check_policy_rules
                ]

            checking -> prompt_needed:
                when: no_cached_decision and requires_prompt
                actions: [
                    prepare_prompt,
                    show_permission_dialog
                ]

            checking -> granted:
                when: cached_permission_granted or policy_allows
                actions: [
                    record_grant,
                    notify_permission_change
                ]

            checking -> denied:
                when: cached_permission_denied or policy_denies
                actions: [
                    record_denial,
                    notify_permission_change
                ]

            prompt_needed -> granted:
                when: user_accepts
                actions: [
                    record_grant,
                    cache_decision,
                    notify_permission_change
                ]

            prompt_needed -> denied:
                when: user_denies or prompt_timeout
                actions: [
                    record_denial,
                    cache_decision,
                    notify_permission_change
                ]

            granted -> revoked:
                when: permission_revoked
                actions: [
                    record_revocation,
                    notify_permission_change,
                    cleanup_resources
                ]

            denied -> prompt_needed:
                when: retry_requested and can_retry
                actions: [
                    reset_denial_count,
                    prepare_prompt
                ]

            any -> error:
                when: system_error
                actions: [
                    log_error,
                    notify_error,
                    cleanup_state
                ]

        error_handlers:
            prompt_error:
                actions: [
                    log_prompt_error,
                    retry_prompt,
                    notify_if_fatal
                ]

            policy_error:
                actions: [
                    log_policy_error,
                    use_default_policy,
                    notify_admin
                ]

            storage_error:
                actions: [
                    log_storage_error,
                    use_memory_cache,
                    schedule_retry
                ]
