-schema=delivery_manager_api
    version = 1.0

-import
    notification = "../types/notification.l"

-api
    DeliveryManager:
        DeliverNotification:
            input: {
                notification: notification.Notification,
                channel: notification.Channel
            }
            output: {
                success: bool,
                status?: notification.DeliveryStatus,
                error?: string
            }

        BatchDeliver:
            input: {
                notifications: [notification.Notification],
                channel: notification.Channel
            }
            output: {
                successes: int,
                failures: int,
                error?: string
            }

        RetryDelivery:
            input: {
                notification_id: string,
                channels?: [string]
            }
            output: {
                success: bool,
                status?: notification.DeliveryStatus,
                error?: string
            }

        VerifyChannel:
            input: {
                channel: notification.Channel,
                test_message?: string
            }
            output: {
                verified: bool,
                details?: object,
                error?: string
            }

        UpdateChannelStatus:
            input: {
                channel_id: string,
                status: notification.ChannelStatus
            }
            output: {
                success: bool,
                error?: string
            }

        GetDeliveryStats:
            input: {
                channel_type: notification.ChannelType,
                timerange: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                stats: object,
                error?: string
            }

-rules
    DeliveryExecution:
        when: delivery_started
        validate:
            - verify_notification
            - check_channel
            - validate_schedule
        actions:
            - prepare_delivery
            - send_notification
            - update_status

    BatchProcessing:
        when: batch_started
        validate:
            - verify_batch
            - check_channel
            - validate_limits
        actions:
            - process_batch
            - track_progress
            - handle_failures

    ChannelVerification:
        when: verification_requested
        validate:
            - verify_channel
            - check_credentials
            - validate_config
        actions:
            - test_connection
            - verify_delivery
            - update_status
