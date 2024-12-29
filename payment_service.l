-schema=payment_service
    version = 1.0
    name    = Payment Service State Machine
    author  = Generated
    date    = 2024/12/29
    copyright = Copyright (c) 2024

-states
    start

    # Apple Pay states
    apple_pay_initiated
    apple_pay_authorizing
    apple_pay_authorized
    apple_pay_processing
    apple_pay_completed
    apple_pay_failed

    # Google Pay states
    google_pay_initiated
    google_pay_authorizing
    google_pay_authorized
    google_pay_processing
    google_pay_completed
    google_pay_failed

    # Common states
    payment_completed
    payment_failed
    payment_refunding
    payment_refunded
    error

-events
    # Apple Pay events
    init_apple_pay     = "Initialize Apple Pay"
    apple_auth_request = "Request Apple Pay authorization"
    apple_auth_success = "Apple Pay authorization successful"
    apple_auth_failed  = "Apple Pay authorization failed"
    apple_process      = "Process Apple Pay payment"
    apple_success      = "Apple Pay payment successful"
    apple_failed       = "Apple Pay payment failed"

    # Google Pay events
    init_google_pay    = "Initialize Google Pay"
    google_auth_request = "Request Google Pay authorization"
    google_auth_success = "Google Pay authorization successful"
    google_auth_failed  = "Google Pay authorization failed"
    google_process     = "Process Google Pay payment"
    google_success     = "Google Pay payment successful"
    google_failed      = "Google Pay payment failed"

    # Common events
    request_refund     = "Request payment refund"
    process_refund     = "Process refund request"
    refund_success     = "Refund successful"
    refund_failed      = "Refund failed"
    retry_payment      = "Retry failed payment"
    error              = "Error occurred"
    cancel_payment     = "Cancel payment"

-transitions
    # Apple Pay Flow
    start              init_apple_pay    apple_pay_initiated
    apple_pay_initiated apple_auth_request apple_pay_authorizing
    apple_pay_authorizing apple_auth_success apple_pay_authorized
    apple_pay_authorizing apple_auth_failed apple_pay_failed
    apple_pay_authorized apple_process    apple_pay_processing
    apple_pay_processing apple_success    apple_pay_completed
    apple_pay_processing apple_failed     apple_pay_failed
    apple_pay_completed                   payment_completed
    apple_pay_failed    retry_payment     apple_pay_initiated
    apple_pay_failed    cancel_payment    payment_failed

    # Google Pay Flow
    start              init_google_pay   google_pay_initiated
    google_pay_initiated google_auth_request google_pay_authorizing
    google_pay_authorizing google_auth_success google_pay_authorized
    google_pay_authorizing google_auth_failed google_pay_failed
    google_pay_authorized google_process   google_pay_processing
    google_pay_processing google_success   google_pay_completed
    google_pay_processing google_failed    google_pay_failed
    google_pay_completed                   payment_completed
    google_pay_failed   retry_payment     google_pay_initiated
    google_pay_failed   cancel_payment    payment_failed

    # Refund Flow
    payment_completed  request_refund    payment_refunding
    payment_refunding  process_refund    payment_refunding
    payment_refunding  refund_success    payment_refunded
    payment_refunding  refund_failed     payment_completed

    # Error Handling
    error             retry_payment      start
