-schema=profiler_types
    version = 1.0

-types
    Profile:
        id: string
        type: ProfileType
        title: string
        start_time: timestamp
        end_time?: timestamp
        nodes: [ProfileNode]

    ProfileType:
        enum:
            - CPU
            - HEAP
            - COVERAGE

    ProfileNode:
        id: string
        call_frame: CallFrame
        hit_count: int
        children: [string]  # child node ids
        self_time: float
        total_time: float

    CallFrame:
        function_name: string
        script_id: string
        url: string
        line_number: int
        column_number: int

    HeapSnapshot:
        nodes: [HeapNode]
        edges: [HeapEdge]
        samples?: [HeapSample]

    HeapNode:
        id: string
        name: string
        type: HeapNodeType
        self_size: int
        retained_size: int
        edge_count: int
        trace_node_id?: string

    HeapNodeType:
        enum:
            - OBJECT
            - CLOSURE
            - STRING
            - NUMBER
            - ARRAY
            - REGEXP
            - HEAP_NUMBER

    HeapEdge:
        from: string  # source node id
        to: string   # target node id
        type: HeapEdgeType
        name_or_index: string

    HeapEdgeType:
        enum:
            - CONTEXT
            - ELEMENT
            - PROPERTY
            - INTERNAL
            - HIDDEN
            - SHORTCUT
            - WEAK

    HeapSample:
        size: int
        timestamp: timestamp
        last_assigned_id: string

    Coverage:
        url: string
        functions: [FunctionCoverage]

    FunctionCoverage:
        function_name: string
        ranges: [CoverageRange]
        is_block_coverage: bool

    CoverageRange:
        start_offset: int
        end_offset: int
        count: int
