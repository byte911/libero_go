-schema=api_manager_api
    version = 1.0

-import
    api = "../types/api.l"

-api
    APIManager:
        CreateAPI:
            input: {
                api: api.API
            }
            output: {
                api_id: string,
                error?: string
            }

        AddEndpoint:
            input: {
                api_id: string,
                endpoint: api.Endpoint
            }
            output: {
                endpoint_id: string,
                error?: string
            }

        ConfigureHandler:
            input: {
                endpoint_id: string,
                handler: api.Handler
            }
            output: {
                handler_id: string,
                error?: string
            }

        AddMiddleware:
            input: {
                handler_id: string,
                middleware: api.Middleware
            }
            output: {
                middleware_id: string,
                error?: string
            }

        HandleRequest:
            input: {
                request: api.APIRequest
            }
            output: {
                response?: api.APIResponse,
                error?: string
            }

        ValidateRequest:
            input: {
                request: api.APIRequest,
                config: api.ValidationConfig
            }
            output: {
                valid: bool,
                errors?: [string]
            }

        MonitorAPI:
            input: {
                api_id: string,
                metrics: [string]
            }
            output: {
                metrics?: api.APIMetrics,
                error?: string
            }

        GenerateReport:
            input: {
                api_id: string,
                timerange: {
                    start: timestamp,
                    end: timestamp
                }
            }
            output: {
                report?: api.APIReport,
                error?: string
            }

-rules
    RequestHandling:
        when: request_received
        validate:
            - verify_request
            - check_auth
            - validate_params
        actions:
            - process_request
            - execute_handlers
            - send_response

    EndpointManagement:
        when: endpoint_added
        validate:
            - verify_endpoint
            - check_path
            - validate_config
        actions:
            - register_endpoint
            - setup_handlers
            - verify_setup

    MiddlewareProcessing:
        when: middleware_added
        validate:
            - verify_middleware
            - check_priority
            - validate_config
        actions:
            - register_middleware
            - setup_chain
            - verify_order
