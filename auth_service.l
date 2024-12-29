-schema=auth_service
    version = 1.0
    name    = Auth Service State Machine
    author  = Generated
    date    = 2024/12/29
    copyright = Copyright (c) 2024

-states
    start
    authenticating
    authenticating_apple
    authenticating_google
    waiting_apple_callback
    waiting_google_callback
    sending_email_code
    waiting_email_code
    verifying_email_code
    authenticated
    error
    logged_out

    # Account deletion states
    deletion_requested
    verifying_deletion_password
    verifying_deletion_apple
    verifying_deletion_google
    verifying_deletion_email
    waiting_deletion_email_code
    confirming_deletion
    account_deleted

-events
    login               = "User attempts to login with username/password"
    login_apple        = "User attempts to login with Apple"
    login_google       = "User attempts to login with Google"
    login_email        = "User attempts to login with email"
    apple_callback     = "Received callback from Apple"
    google_callback    = "Received callback from Google"
    auth_ok           = "Authentication successful"
    auth_fail         = "Authentication failed"
    logout            = "User logs out"
    error             = "System error occurred"
    retry             = "Retry authentication"
    send_code         = "Send verification code"
    code_sent         = "Verification code sent successfully"
    submit_code       = "User submits verification code"
    code_valid        = "Verification code is valid"
    code_invalid      = "Verification code is invalid"
    code_expired      = "Verification code has expired"
    resend_code       = "Resend verification code"

    # Account deletion events
    request_deletion   = "User requests account deletion"
    verify_password    = "Verify password for deletion"
    verify_apple      = "Verify Apple account for deletion"
    verify_google     = "Verify Google account for deletion"
    verify_email      = "Verify email for deletion"
    deletion_verified = "Account verification for deletion successful"
    deletion_denied   = "Account verification for deletion failed"
    confirm_deletion  = "User confirms account deletion"
    cancel_deletion   = "User cancels account deletion"
    deletion_complete = "Account deletion completed"

-transitions
    # Traditional login flow
    start               login           authenticating
    authenticating      auth_ok         authenticated
    authenticating      auth_fail       error
    authenticating      error           error

    # Apple login flow
    start               login_apple     authenticating_apple
    authenticating_apple auth_fail      error
    authenticating_apple error          error
    authenticating_apple auth_ok        waiting_apple_callback
    waiting_apple_callback apple_callback authenticated
    waiting_apple_callback error        error
    waiting_apple_callback auth_fail    error

    # Google login flow
    start               login_google    authenticating_google
    authenticating_google auth_fail     error
    authenticating_google error         error
    authenticating_google auth_ok       waiting_google_callback
    waiting_google_callback google_callback authenticated
    waiting_google_callback error       error
    waiting_google_callback auth_fail   error

    # Email verification code flow
    start               login_email     sending_email_code
    sending_email_code  code_sent      waiting_email_code
    sending_email_code  error          error
    waiting_email_code  submit_code    verifying_email_code
    waiting_email_code  resend_code    sending_email_code
    waiting_email_code  code_expired   error
    verifying_email_code code_valid    authenticated
    verifying_email_code code_invalid  waiting_email_code
    verifying_email_code error         error

    # Account deletion flows
    authenticated       request_deletion    deletion_requested

    # Password account deletion flow
    deletion_requested  verify_password    verifying_deletion_password
    verifying_deletion_password deletion_verified confirming_deletion
    verifying_deletion_password deletion_denied  authenticated

    # Apple account deletion flow
    deletion_requested  verify_apple       verifying_deletion_apple
    verifying_deletion_apple deletion_verified confirming_deletion
    verifying_deletion_apple deletion_denied   authenticated

    # Google account deletion flow
    deletion_requested  verify_google      verifying_deletion_google
    verifying_deletion_google deletion_verified confirming_deletion
    verifying_deletion_google deletion_denied  authenticated

    # Email account deletion flow
    deletion_requested  verify_email       verifying_deletion_email
    verifying_deletion_email code_sent    waiting_deletion_email_code
    waiting_deletion_email_code submit_code verifying_deletion_email
    waiting_deletion_email_code code_expired authenticated
    verifying_deletion_email deletion_verified confirming_deletion
    verifying_deletion_email deletion_denied authenticated

    # Final deletion confirmation
    confirming_deletion confirm_deletion  account_deleted
    confirming_deletion cancel_deletion   authenticated
    account_deleted     login            start

    # Common states
    authenticated       logout          logged_out
    error              retry           start
    logged_out         login           authenticating
    logged_out         login_apple     authenticating_apple
    logged_out         login_google    authenticating_google
    logged_out         login_email     sending_email_code
