-schema=order_service
    version = 1.0
    name    = Order and Subscription Service State Machine
    author  = Generated
    date    = 2024/12/29
    copyright = Copyright (c) 2024

-states
    # Order states
    start
    cart_pending
    order_created
    payment_pending
    payment_processing
    payment_failed
    order_paid
    order_fulfilled
    order_cancelled
    order_refunded

    # Subscription states
    subscription_created
    subscription_active
    subscription_payment_due
    subscription_payment_failed
    subscription_paused
    subscription_cancelled
    subscription_expired

    # Common states
    error

-events
    # Order events
    add_to_cart        = "Add item to cart"
    remove_from_cart   = "Remove item from cart"
    create_order       = "Create order from cart"
    update_order       = "Update order details"
    cancel_order       = "Cancel order"
    initiate_payment   = "Start payment process"
    payment_success    = "Payment successful"
    payment_failed     = "Payment failed"
    retry_payment      = "Retry failed payment"
    request_refund     = "Request refund"
    approve_refund     = "Approve refund request"
    deny_refund        = "Deny refund request"
    fulfill_order      = "Mark order as fulfilled"

    # Subscription events
    create_subscription = "Create new subscription"
    activate_subscription = "Activate subscription"
    pause_subscription  = "Pause subscription"
    resume_subscription = "Resume subscription"
    cancel_subscription = "Cancel subscription"
    renew_subscription  = "Renew subscription"
    payment_due        = "Subscription payment is due"
    grace_period_expired = "Grace period expired"

    # Common events
    error              = "Error occurred"
    retry              = "Retry operation"

-transitions
    # Cart and Order Creation Flow
    start              add_to_cart      cart_pending
    cart_pending       add_to_cart      cart_pending
    cart_pending       remove_from_cart cart_pending
    cart_pending       create_order     order_created

    # Payment Flow
    order_created      initiate_payment payment_pending
    payment_pending    payment_success  order_paid
    payment_pending    payment_failed   payment_failed
    payment_failed     retry_payment    payment_processing
    payment_processing payment_success  order_paid
    payment_processing payment_failed   payment_failed

    # Order Fulfillment Flow
    order_paid         fulfill_order    order_fulfilled

    # Order Cancellation Flow
    order_created      cancel_order     order_cancelled
    payment_pending    cancel_order     order_cancelled
    payment_failed     cancel_order     order_cancelled

    # Refund Flow
    order_paid         request_refund   payment_pending
    order_fulfilled    request_refund   payment_pending
    payment_pending    approve_refund   order_refunded
    payment_pending    deny_refund      order_paid

    # Subscription Creation Flow
    order_paid         create_subscription subscription_created
    subscription_created activate_subscription subscription_active

    # Subscription Lifecycle
    subscription_active payment_due     subscription_payment_due
    subscription_payment_due payment_success subscription_active
    subscription_payment_due payment_failed subscription_payment_failed
    subscription_payment_failed retry_payment subscription_payment_due
    subscription_payment_failed grace_period_expired subscription_expired

    # Subscription Management
    subscription_active pause_subscription subscription_paused
    subscription_paused resume_subscription subscription_active
    subscription_active cancel_subscription subscription_cancelled
    subscription_paused cancel_subscription subscription_cancelled
    subscription_payment_due cancel_subscription subscription_cancelled
    subscription_payment_failed cancel_subscription subscription_cancelled

    # Subscription Renewal
    subscription_active renew_subscription subscription_active

    # Error Handling
    error             retry            start
