-schema=indexeddb_types
    version = 1.0

-import
    storage = "./storage.l"

-types
    Database:
        name: string
        version: int
        stores: [ObjectStore]
        origin: storage.StorageKey

    ObjectStore:
        name: string
        key_path?: string
        auto_increment: bool
        indexes: [Index]

    Index:
        name: string
        key_path: string
        unique: bool
        multi_entry: bool
        locale?: string

    KeyRange:
        lower?: any
        upper?: any
        lower_open: bool
        upper_open: bool

    Cursor:
        source: CursorSource
        direction: Direction
        key: any
        primary_key: any
        value: any

    CursorSource:
        type: SourceType
        name: string

    SourceType:
        enum:
            - OBJECT_STORE
            - INDEX

    Direction:
        enum:
            - NEXT
            - NEXT_UNIQUE
            - PREV
            - PREV_UNIQUE

    IDBTransaction:
        id: string
        mode: TransactionMode
        scope: [string]
        database: string
        active: bool
        error?: string

    TransactionMode:
        enum:
            - READ_ONLY
            - READ_WRITE
            - VERSION_CHANGE

    IDBRequest:
        transaction: string
        source: RequestSource
        ready_state: ReadyState
        result?: any
        error?: string

    RequestSource:
        type: SourceType
        name: string

    ReadyState:
        enum:
            - PENDING
            - DONE

    VersionChange:
        old_version: int
        new_version: int
        database: string
