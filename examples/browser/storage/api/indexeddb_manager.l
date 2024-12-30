-schema=indexeddb_manager_api
    version = 1.0

-import
    storage = "../types/storage.l"
    indexeddb = "../types/indexeddb.l"

-api
    IndexedDBManager:
        OpenDatabase:
            input: {
                name: string,
                version?: int,
                origin: storage.StorageKey
            }
            output: {
                database?: indexeddb.Database,
                error?: string
            }

        DeleteDatabase:
            input: {
                name: string,
                origin: storage.StorageKey
            }
            output: {
                success: bool,
                error?: string
            }

        ListDatabases:
            input: {
                origin?: storage.StorageKey
            }
            output: {
                databases: indexeddb.Database[],
                error?: string
            }

        CreateObjectStore:
            input: {
                database: string,
                store: indexeddb.ObjectStore
            }
            output: {
                success: bool,
                error?: string
            }

        DeleteObjectStore:
            input: {
                database: string,
                store_name: string
            }
            output: {
                success: bool,
                error?: string
            }

        CreateIndex:
            input: {
                database: string,
                store_name: string,
                index: indexeddb.Index
            }
            output: {
                success: bool,
                error?: string
            }

        DeleteIndex:
            input: {
                database: string,
                store_name: string,
                index_name: string
            }
            output: {
                success: bool,
                error?: string
            }

        BeginTransaction:
            input: {
                database: string,
                mode: indexeddb.TransactionMode,
                stores: [string]
            }
            output: {
                transaction?: indexeddb.IDBTransaction,
                error?: string
            }

        Put:
            input: {
                transaction: string,
                store: string,
                value: any,
                key?: any
            }
            output: {
                key: any,
                error?: string
            }

        Get:
            input: {
                transaction: string,
                store: string,
                key: any
            }
            output: {
                value?: any,
                error?: string
            }

        Delete:
            input: {
                transaction: string,
                store: string,
                key: any
            }
            output: {
                success: bool,
                error?: string
            }

        Clear:
            input: {
                transaction: string,
                store: string
            }
            output: {
                success: bool,
                error?: string
            }

        OpenCursor:
            input: {
                transaction: string,
                source: indexeddb.CursorSource,
                range?: indexeddb.KeyRange,
                direction?: indexeddb.Direction
            }
            output: {
                cursor?: indexeddb.Cursor,
                error?: string
            }

-rules
    VersionChange:
        when: database_upgrade
        validate:
            - verify_version_increment
            - validate_schema_changes
            - check_data_migration
        actions:
            - apply_schema_changes
            - migrate_data
            - update_version

    TransactionLifecycle:
        when: transaction_state_change
        validate:
            - verify_transaction_scope
            - check_transaction_mode
            - validate_operations
        actions:
            - update_transaction_state
            - notify_transaction_complete

    IndexMaintenance:
        when: index_operation
        validate:
            - verify_index_integrity
            - check_unique_constraints
            - validate_key_paths
        actions:
            - update_index_entries
            - reindex_if_needed
