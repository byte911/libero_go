-schema=render_engine
    version = 1.0

-import
    dom = "../types/dom.l"
    css = "../types/css.l"

-types
    RenderNode:
        dom_node: dom.Node
        style: css.ComputedStyle
        layout: Layout
        children: [RenderNode]
        flags: RenderFlags

    Layout:
        x: float
        y: float
        width: float
        height: float
        margin: BoxMetrics
        padding: BoxMetrics
        border: BoxMetrics

    BoxMetrics:
        top: float
        right: float
        bottom: float
        left: float

    RenderFlags:
        needs_layout: bool
        needs_paint: bool
        is_visible: bool
        is_positioned: bool
        contains_text: bool

    PaintLayer:
        id: string
        z_index: int
        opacity: float
        transform: Transform
        clip: Rect
        items: [PaintItem]

    PaintItem:
        type: PaintType
        bounds: Rect
        style: PaintStyle

    PaintType:
        enum:
            - BACKGROUND
            - BORDER
            - TEXT
            - IMAGE
            - SVG
            - VIDEO

    Transform:
        matrix: [float]  # 3x3 matrix
        origin: Point

    Rect:
        x: float
        y: float
        width: float
        height: float

    Point:
        x: float
        y: float

-api
    RenderEngine:
        # 布局计算
        CalculateLayout:
            input: {
                root: dom.Node,
                viewport: {
                    width: int,
                    height: int
                },
                media_context: {
                    device_type: string,
                    color_scheme: string,
                    pixel_ratio: float
                }
            }
            output: {
                render_tree: RenderNode,
                layout_metrics: {
                    total_time: int,
                    reflow_count: int,
                    optimization_applied: [string]
                }
            }

        # 绘制操作
        Paint:
            input: {
                render_tree: RenderNode,
                dirty_region?: Rect,
                flags: {
                    force_full_repaint: bool,
                    hardware_accelerated: bool,
                    debug_layers: bool
                }
            }
            output: {
                layers: [PaintLayer],
                metrics: {
                    paint_time: int,
                    layer_count: int,
                    pixels_painted: int
                }
            }

        # 合成操作
        Composite:
            input: {
                layers: [PaintLayer],
                viewport: Rect,
                device_scale: float
            }
            output: {
                frame_buffer: string,  # 指向最终渲染缓冲区的引用
                metrics: {
                    composite_time: int,
                    layer_updates: int,
                    memory_used: int
                }
            }

        # 处理动画
        AnimateElements:
            input: {
                animations: [css.Animation],
                timestamp: int
            }
            output: {
                updated_nodes: [RenderNode],
                completed_animations: [string]
            }

        # 优化提示
        OptimizeRendering:
            input: {
                render_tree: RenderNode,
                performance_hints: {
                    target_fps: int,
                    memory_limit: int,
                    battery_saving: bool
                }
            }
            output: {
                optimization_plan: {
                    layer_suggestions: [string],
                    caching_strategy: string,
                    performance_warnings: [string]
                }
            }
