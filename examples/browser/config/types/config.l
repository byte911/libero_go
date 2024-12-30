-schema=config_types
    version = 1.0

-types
    Config:
        id: string
        name: string
        version: string
        environment: string
        sections: [ConfigSection]
        metadata: ConfigMetadata

    ConfigSection:
        name: string
        description?: string
        items: [ConfigItem]
        dependencies?: [string]

    ConfigItem:
        key: string
        value: any
        type: ValueType
        metadata: ItemMetadata
        validation?: ValidationRule

    ValueType:
        enum:
            - STRING
            - NUMBER
            - BOOLEAN
            - ARRAY
            - OBJECT
            - SECRET

    ItemMetadata:
        description?: string
        default?: any
        required: bool
        mutable: bool
        sensitive: bool
        tags: [string]

    ValidationRule:
        type: ValidationType
        params: object
        message?: string

    ValidationType:
        enum:
            - RANGE
            - PATTERN
            - ENUM
            - CUSTOM

    ConfigMetadata:
        created: timestamp
        updated: timestamp
        author: string
        version: string
        environment: string

    ConfigChange:
        id: string
        timestamp: timestamp
        user: string
        type: ChangeType
        items: [ChangeItem]

    ChangeType:
        enum:
            - CREATE
            - UPDATE
            - DELETE
            - REVERT

    ChangeItem:
        key: string
        old_value?: any
        new_value?: any
        reason?: string

    ConfigSnapshot:
        id: string
        timestamp: timestamp
        config_id: string
        version: string
        data: object

    ConfigTemplate:
        id: string
        name: string
        description?: string
        sections: [TemplateSection]
        variables: [TemplateVariable]

    TemplateSection:
        name: string
        content: string
        variables: [string]

    TemplateVariable:
        name: string
        type: ValueType
        default?: any
        description?: string

    ConfigValidation:
        config_id: string
        timestamp: timestamp
        status: ValidationStatus
        issues: [ValidationIssue]

    ValidationStatus:
        enum:
            - VALID
            - WARNING
            - ERROR

    ValidationIssue:
        type: IssueType
        key: string
        message: string
        severity: IssueSeverity

    IssueType:
        enum:
            - MISSING_REQUIRED
            - INVALID_VALUE
            - TYPE_MISMATCH
            - DEPENDENCY_ERROR

    IssueSeverity:
        enum:
            - ERROR
            - WARNING
            - INFO

    ConfigReport:
        id: string
        timestamp: timestamp
        config_id: string
        changes: [ConfigChange]
        validations: [ConfigValidation]
        metrics: ConfigMetrics

    ConfigMetrics:
        total_items: int
        changes: int
        validations: int
        issues: {string: int}
