-schema=window_manager_api
    version = 1.0

-import
    window = "../types/window.l"

-api
    WindowManager:
        CreateWindow:
            input: {
                type: window.WindowType,
                bounds?: window.Bounds,
                state?: window.WindowState
            }
            output: {
                window?: window.Window,
                error?: string
            }

        DestroyWindow:
            input: {
                id: string
            }
            output: {
                success: bool,
                error?: string
            }

        UpdateWindow:
            input: {
                id: string,
                bounds?: window.Bounds,
                state?: window.WindowState
            }
            output: {
                success: bool,
                error?: string
            }

        GetActiveWindow:
            input: {}
            output: {
                window?: window.Window,
                error?: string
            }

        SetActiveWindow:
            input: {
                id: string
            }
            output: {
                success: bool,
                error?: string
            }

        GetDisplays:
            input: {}
            output: {
                displays: window.Display[],
                error?: string
            }

        GetPrimaryDisplay:
            input: {}
            output: {
                display?: window.Display,
                error?: string
            }

        MoveWindow:
            input: {
                id: string,
                x: int,
                y: int,
                animate?: bool
            }
            output: {
                success: bool,
                error?: string
            }

        ResizeWindow:
            input: {
                id: string,
                width: int,
                height: int,
                animate?: bool
            }
            output: {
                success: bool,
                error?: string
            }

        MinimizeWindow:
            input: {
                id: string
            }
            output: {
                success: bool,
                error?: string
            }

        MaximizeWindow:
            input: {
                id: string
            }
            output: {
                success: bool,
                error?: string
            }

        FullscreenWindow:
            input: {
                id: string,
                display?: string
            }
            output: {
                success: bool,
                error?: string
            }

-rules
    WindowLifecycle:
        when: window_state_change
        validate:
            - verify_window_type
            - check_bounds
            - validate_state
            - check_display_constraints
        actions:
            - update_window_tree
            - notify_widgets
            - trigger_animation

    DisplayManagement:
        when: display_change
        validate:
            - verify_display_config
            - check_resolution
            - validate_scale_factor
        actions:
            - update_displays
            - adjust_windows
            - notify_changes

    WindowAnimation:
        when: window_animation
        validate:
            - verify_animation_type
            - check_duration
            - validate_timing
        actions:
            - start_animation
            - update_frames
            - complete_animation
