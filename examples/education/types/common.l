-schema=common_types
    version = 1.0

-types
    # 通用ID类型
    ID: string
    UserId: ID
    CourseId: ID
    ModuleId: ID
    AssignmentId: ID
    SessionId: ID

    # 时间相关
    TimeRange:
        start: timestamp
        end: timestamp
        timezone: string

    # 分页
    PageRequest:
        page: int
        page_size: int
        constraints:
            - page >= 1
            - page_size between 1 and 100

    PageResponse[T]:
        items: [T]
        total: int
        page: int
        page_size: int
        has_next: bool

    # 通用响应
    Response[T]:
        success: bool
        data?: T
        error?: Error

    Error:
        code: string
        message: string
        details?: object

    # 文件
    File:
        id: string
        name: string
        mime_type: string
        size: int
        url: string
        uploaded_at: timestamp
