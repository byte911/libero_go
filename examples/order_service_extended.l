-schema=order_service
    version = 1.0
    name    = Order Service Definition
    author  = Example
    date    = 2024/12/30

# Type definitions
-types
    OrderItem:
        product_id: string
        quantity: int
        price: decimal
        constraints:
            quantity > 0
            price >= 0

    Order:
        id: string
        items: [OrderItem]
        total: decimal
        status: OrderStatus
        customer_id: string
        created_at: timestamp
        updated_at: timestamp
        computed:
            total = sum(items.price * items.quantity)

# State machine definition
-states
    OrderStatus:
        initial: cart_pending
        states:
            cart_pending
            order_created
            payment_pending
            order_paid
            order_fulfilled

# API endpoints
-api
    CreateOrder:
        method: POST
        path: /orders
        input: Order
        output: 
            success: Order
            error: ErrorResponse
        auth: required
        rate_limit: 100/minute

    GetOrder:
        method: GET
        path: /orders/{id}
        params:
            id: string
        output: Order
        auth: required

# Business rules
-rules
    OrderCreation:
        when: event.type == "CreateOrder"
        validate:
            - order.items.length > 0
            - order.total <= customer.credit_limit
        actions:
            - create_payment_request
            - notify_customer

# Event handlers
-events
    OrderCreated:
        producer: OrderService
        payload: Order
        subscribers:
            - InventoryService
            - NotificationService

# Data transformations
-transformers
    OrderToInvoice:
        input: Order
        output: Invoice
        mapping:
            invoice_id = generate_uuid()
            customer_details = lookup_customer(input.customer_id)
            line_items = map(input.items, item => {
                description: item.product_name,
                amount: item.price * item.quantity
            })
