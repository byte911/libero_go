-schema=css_types
    version = 1.0

-types
    Stylesheet:
        rules: [Rule]
        media: MediaQuery
        imports: [string]
        source_file: string

    Rule:
        type: RuleType
        selectors: [Selector]
        declarations: [Declaration]
        media?: MediaQuery
        supports?: SupportsCondition

    RuleType:
        enum:
            - STYLE_RULE
            - MEDIA_RULE
            - IMPORT_RULE
            - FONT_FACE_RULE
            - PAGE_RULE
            - KEYFRAMES_RULE
            - SUPPORTS_RULE

    Selector:
        parts: [SelectorPart]
        specificity: Specificity
        text: string
        computed:
            specificity_value = calculate_specificity(parts)

    SelectorPart:
        type: SelectorPartType
        value: string
        pseudo_class?: string
        pseudo_element?: string
        attribute?: AttributeSelector

    SelectorPartType:
        enum:
            - TYPE
            - CLASS
            - ID
            - UNIVERSAL
            - ATTRIBUTE
            - PSEUDO_CLASS
            - PSEUDO_ELEMENT
            - COMBINATOR

    AttributeSelector:
        name: string
        operator?: string
        value?: string
        case_sensitive: bool

    Specificity:
        id_count: int
        class_count: int
        type_count: int
        computed:
            value = (id_count * 100) + (class_count * 10) + type_count

    Declaration:
        property: string
        value: Value
        important: bool
        source_position: SourcePosition

    Value:
        type: ValueType
        components: [ValueComponent]
        text: string

    ValueType:
        enum:
            - KEYWORD
            - NUMBER
            - DIMENSION
            - PERCENTAGE
            - COLOR
            - STRING
            - URL
            - FUNCTION
            - CALC
            - CUSTOM_PROPERTY

    ValueComponent:
        type: ValueType
        value: string
        unit?: string
        function_name?: string
        arguments?: [Value]

    MediaQuery:
        type: string
        features: [MediaFeature]
        operator?: string
        text: string

    MediaFeature:
        name: string
        value?: Value
        operator?: string

    SupportsCondition:
        conditions: [string]
        operator: string
        text: string

    SourcePosition:
        line: int
        column: int
        source: string

    Animation:
        name: string
        keyframes: [Keyframe]
        timing_function: string
        duration: int
        delay: int
        iteration_count: int
        direction: string
        fill_mode: string

    Keyframe:
        selector: string  # percentage or keywords (from, to)
        declarations: [Declaration]

    # 计算样式系统
    StyleComputation:
        element: Element
        matched_rules: [MatchedRule]
        inherited_styles: ComputedStyle
        computed_style: ComputedStyle

    MatchedRule:
        rule: Rule
        specificity: Specificity
        origin: StyleOrigin
        media_matches: bool

    StyleOrigin:
        enum:
            - USER_AGENT
            - USER
            - AUTHOR
            - AUTHOR_IMPORTANT
