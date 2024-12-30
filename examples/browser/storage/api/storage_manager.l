-schema=storage_manager_api
    version = 1.0

-import
    storage = "../types/storage.l"
    indexeddb = "../types/indexeddb.l"

-api
    StorageManager:
        Estimate:
            input: {
                origin: storage.StorageKey
            }
            output: {
                quota: storage.StorageQuota,
                usage_details: {
                    type: storage.StorageType,
                    usage: int64
                }[]
            }

        RequestQuota:
            input: {
                origin: storage.StorageKey,
                requested: int64,
                type: storage.StorageType
            }
            output: {
                granted: int64,
                error?: string
            }

        ListStorageAreas:
            input: {
                origin?: storage.StorageKey,
                type?: storage.StorageType
            }
            output: {
                areas: storage.StorageArea[]
            }

        ClearStorage:
            input: {
                origin: storage.StorageKey,
                type?: storage.StorageType
            }
            output: {
                success: bool,
                error?: string
            }

        BeginTransaction:
            input: {
                origin: storage.StorageKey,
                type: storage.StorageType,
                mode: storage.TransactionType
            }
            output: {
                transaction: storage.StorageTransaction,
                error?: string
            }

        CommitTransaction:
            input: {
                transaction_id: string
            }
            output: {
                success: bool,
                error?: string
            }

        AbortTransaction:
            input: {
                transaction_id: string
            }
            output: {
                success: bool,
                error?: string
            }

        GetItem:
            input: {
                origin: storage.StorageKey,
                type: storage.StorageType,
                key: string
            }
            output: {
                entry?: storage.StorageEntry,
                error?: string
            }

        SetItem:
            input: {
                origin: storage.StorageKey,
                type: storage.StorageType,
                key: string,
                value: any,
                metadata?: storage.StorageMetadata
            }
            output: {
                success: bool,
                error?: string
            }

        RemoveItem:
            input: {
                origin: storage.StorageKey,
                type: storage.StorageType,
                key: string
            }
            output: {
                success: bool,
                error?: string
            }

        ListItems:
            input: {
                origin: storage.StorageKey,
                type: storage.StorageType,
                pattern?: string,
                limit?: int,
                offset?: int
            }
            output: {
                entries: storage.StorageEntry[],
                total: int,
                has_more: bool
            }

-rules
    QuotaEnforcement:
        when: before_write
        validate:
            - check_quota_available
            - verify_origin_permissions
            - validate_content_size
        actions:
            - update_usage_stats
            - notify_if_near_limit

    TransactionIntegrity:
        when: transaction_operation
        validate:
            - verify_transaction_active
            - check_operation_allowed
            - validate_changes
        actions:
            - record_operation
            - update_transaction_state

    StorageCleanup:
        when: storage_pressure
        validate:
            - check_pressure_threshold
            - identify_unused_storage
            - verify_cleanup_allowed
        actions:
            - remove_expired_entries
            - compact_storage
            - notify_cleanup_complete
