-schema=notification_manager_api
    version = 1.0

-import
    notification = "../types/notification.l"

-api
    NotificationManager:
        SendNotification:
            input: {
                notification: notification.Notification,
                recipients: [string]
            }
            output: {
                notification_id: string,
                error?: string
            }

        RegisterTemplate:
            input: {
                template: notification.NotificationTemplate
            }
            output: {
                template_id: string,
                error?: string
            }

        RegisterRecipient:
            input: {
                recipient: notification.Recipient
            }
            output: {
                recipient_id: string,
                error?: string
            }

        UpdatePreferences:
            input: {
                recipient_id: string,
                preferences: notification.RecipientPreferences
            }
            output: {
                success: bool,
                error?: string
            }

        GetNotificationStatus:
            input: {
                notification_id: string
            }
            output: {
                status?: notification.DeliveryStatus,
                channels: [notification.ChannelStatus],
                error?: string
            }

        GetRecipientStatus:
            input: {
                recipient_id: string
            }
            output: {
                channels: [notification.RecipientChannel],
                preferences?: notification.RecipientPreferences,
                error?: string
            }

        GetMetrics:
            input: {
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                group_by?: [string]
            }
            output: {
                metrics?: notification.NotificationMetrics,
                error?: string
            }

        GenerateReport:
            input: {
                timerange: {
                    start: timestamp,
                    end: timestamp
                },
                options?: {
                    include_failures?: bool,
                    include_insights?: bool
                }
            }
            output: {
                report?: notification.NotificationReport,
                error?: string
            }

-rules
    NotificationDelivery:
        when: notification_sent
        validate:
            - verify_notification
            - check_recipients
            - validate_channels
        actions:
            - process_notification
            - deliver_channels
            - track_status

    RecipientManagement:
        when: recipient_updated
        validate:
            - verify_recipient
            - check_channels
            - validate_preferences
        actions:
            - update_recipient
            - verify_channels
            - sync_preferences

    MetricsCollection:
        when: metrics_requested
        validate:
            - verify_timerange
            - check_grouping
            - validate_access
        actions:
            - collect_metrics
            - calculate_stats
            - generate_insights
