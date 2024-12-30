-schema=same_origin_policy
    version = 1.0

-import
    origin = "../types/origin.l"

-types
    CrossOriginRequest:
        source: origin.Origin
        target: origin.Origin
        request_type: RequestType
        credentials: bool
        headers: [string]
        methods: [string]

    RequestType:
        enum:
            - FETCH
            - XHR
            - FORM
            - IFRAME
            - SCRIPT
            - STYLE
            - IMAGE
            - MEDIA
            - FONT

    AccessControl:
        allow_origin: [origin.Origin]
        allow_methods: [string]
        allow_headers: [string]
        expose_headers: [string]
        allow_credentials: bool
        max_age: int

    CrossOriginAccess:
        type: AccessType
        source: origin.Origin
        target: origin.Origin
        permissions: [string]

    AccessType:
        enum:
            - DOM_ACCESS
            - STORAGE_ACCESS
            - NETWORK_ACCESS
            - COOKIE_ACCESS

-api
    SameOriginPolicy:
        ValidateRequest:
            input: {
                request: CrossOriginRequest,
                context: {
                    initiator: string,
                    target_info: {
                        cors_headers?: AccessControl,
                        resource_type: string
                    }
                }
            }
            output: {
                allowed: bool,
                reason?: string,
                required_preflight: bool
            }

        CheckAccess:
            input: {
                access: CrossOriginAccess,
                context: {
                    window_context?: string,
                    document_domain?: string
                }
            }
            output: {
                allowed: bool,
                reason?: string
            }

        ModifyOrigin:
            input: {
                origin: origin.Origin,
                modification: {
                    document_domain?: string,
                    port?: int
                }
            }
            output: {
                success: bool,
                new_origin?: origin.Origin,
                error?: string
            }

-rules
    RequestValidation:
        when: before_cross_origin_request
        validate:
            - verify_origin_match(source, target)
            - check_cors_headers(request, cors_config)
            - validate_methods(request.methods)
            - validate_headers(request.headers)
        actions:
            - add_cors_headers
            - perform_preflight_if_needed
            - log_access_attempt

    DOMAccess:
        when: before_dom_access
        validate:
            - check_same_origin(source, target)
            - verify_document_domain
            - check_frame_ancestry
        actions:
            - grant_or_deny_access
            - log_access_attempt

    StorageAccess:
        when: before_storage_access
        validate:
            - check_same_origin(source, target)
            - verify_third_party_context
            - check_storage_permission
        actions:
            - grant_or_deny_access
            - log_access_attempt
