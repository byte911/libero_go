-schema=widget_manager_api
    version = 1.0

-import
    widget = "../types/widget.l"

-api
    WidgetManager:
        CreateWidget:
            input: {
                type: widget.WidgetType,
                parent?: string,
                style?: widget.Style,
                layout?: widget.Layout
            }
            output: {
                widget?: widget.Widget,
                error?: string
            }

        DestroyWidget:
            input: {
                id: string
            }
            output: {
                success: bool,
                error?: string
            }

        UpdateWidget:
            input: {
                id: string,
                state?: widget.WidgetState,
                style?: widget.Style,
                layout?: widget.Layout
            }
            output: {
                success: bool,
                error?: string
            }

        AddChild:
            input: {
                parent: string,
                child: string,
                index?: int
            }
            output: {
                success: bool,
                error?: string
            }

        RemoveChild:
            input: {
                parent: string,
                child: string
            }
            output: {
                success: bool,
                error?: string
            }

        AddEventHandler:
            input: {
                widget: string,
                handler: widget.EventHandler
            }
            output: {
                handler_id: string,
                error?: string
            }

        RemoveEventHandler:
            input: {
                widget: string,
                handler_id: string
            }
            output: {
                success: bool,
                error?: string
            }

        UpdateStyle:
            input: {
                widget: string,
                style: widget.Style
            }
            output: {
                success: bool,
                error?: string
            }

        UpdateLayout:
            input: {
                widget: string,
                layout: widget.Layout
            }
            output: {
                success: bool,
                error?: string
            }

        UpdateAccessibility:
            input: {
                widget: string,
                accessibility: widget.Accessibility
            }
            output: {
                success: bool,
                error?: string
            }

-rules
    WidgetLifecycle:
        when: widget_state_change
        validate:
            - verify_parent_exists
            - check_widget_type
            - validate_style
            - check_layout_constraints
        actions:
            - update_widget_tree
            - notify_parent
            - trigger_layout

    EventHandling:
        when: event_triggered
        validate:
            - verify_handler_exists
            - check_event_type
            - validate_callback
        actions:
            - execute_handler
            - propagate_event
            - update_state

    LayoutUpdate:
        when: layout_changed
        validate:
            - verify_layout_type
            - check_constraints
            - validate_dimensions
        actions:
            - recalculate_layout
            - update_children
            - trigger_paint
