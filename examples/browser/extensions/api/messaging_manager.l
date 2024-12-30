-schema=messaging_manager_api
    version = 1.0

-import
    messaging = "../types/messaging.l"

-api
    MessagingManager:
        SendMessage:
            input: {
                message: messaging.Message,
                options?: {
                    timeout?: int,
                    retry?: bool
                }
            }
            output: {
                response?: messaging.Message,
                error?: string
            }

        Connect:
            input: {
                source: messaging.MessageEndpoint,
                target: messaging.MessageEndpoint,
                name?: string
            }
            output: {
                port?: messaging.Port,
                error?: string
            }

        Disconnect:
            input: {
                port_id: string
            }
            output: {
                success: bool,
                error?: string
            }

        CreateMessageQueue:
            input: {
                filters: messaging.MessageFilter[],
                options?: {
                    max_size?: int,
                    persistent?: bool
                }
            }
            output: {
                queue?: messaging.MessageQueue,
                error?: string
            }

        RegisterNativeApp:
            input: {
                manifest: messaging.NativeMessaging
            }
            output: {
                success: bool,
                error?: string
            }

        ListenForMessages:
            input: {
                filters?: messaging.MessageFilter[],
                callback: function
            }
            output: {
                listener_id: string,
                error?: string
            }

        RemoveListener:
            input: {
                listener_id: string
            }
            output: {
                success: bool,
                error?: string
            }

-rules
    MessageRouting:
        when: message_received
        validate:
            - verify_endpoints
            - check_permissions
            - validate_message_format
        actions:
            - route_message
            - notify_listeners
            - update_queue

    PortManagement:
        when: port_state_change
        validate:
            - verify_port_state
            - check_connection_limits
            - validate_endpoints
        actions:
            - update_port_state
            - notify_endpoints
            - cleanup_if_needed

    NativeMessaging:
        when: native_app_communication
        validate:
            - verify_app_manifest
            - check_host_permissions
            - validate_message_size
        actions:
            - launch_native_app
            - establish_pipe
            - monitor_connection
