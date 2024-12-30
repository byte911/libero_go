-schema=storage_types
    version = 1.0

-import
    origin = "../../security/types/origin.l"

-types
    StorageQuota:
        origin: origin.Origin
        usage: int64
        quota: int64
        temporary: bool
        computed:
            remaining = quota - usage
            usage_percent = (usage / quota) * 100

    StorageArea:
        type: StorageType
        origin: origin.Origin
        path: string
        size: int64
        last_access: timestamp
        encrypted: bool

    StorageType:
        enum:
            - LOCAL_STORAGE
            - SESSION_STORAGE
            - INDEXED_DB
            - CACHE_STORAGE
            - FILE_SYSTEM
            - WEB_SQL
            - COOKIES

    StorageKey:
        origin: origin.Origin
        partition_key?: string
        top_level_site?: string

    StorageEntry:
        key: string
        value: any
        size: int64
        created: timestamp
        modified: timestamp
        expires?: timestamp
        metadata: StorageMetadata

    StorageMetadata:
        content_type?: string
        encoding?: string
        compression?: string
        encryption?: {
            algorithm: string,
            key_id: string,
            iv: string
        }
        tags: [string]
        version: int

    StorageTransaction:
        id: string
        type: TransactionType
        origin: origin.Origin
        storage_type: StorageType
        operations: [StorageOperation]
        status: TransactionStatus
        start_time: timestamp
        end_time?: timestamp

    TransactionType:
        enum:
            - READ_ONLY
            - READ_WRITE

    TransactionStatus:
        enum:
            - PENDING
            - ACTIVE
            - COMMITTED
            - ABORTED
            - FAILED

    StorageOperation:
        type: OperationType
        key: string
        value?: any
        old_value?: any
        timestamp: timestamp

    OperationType:
        enum:
            - GET
            - SET
            - DELETE
            - CLEAR
            - ITERATE
