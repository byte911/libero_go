package order

import (
	"context"

	"encore.dev/beta/errs"
)

// AddToCartRequest represents the request to add an item to cart
type AddToCartRequest struct {
	UserID     string  `json:"user_id"`
	ProductID  string  `json:"product_id"`
	Quantity   int     `json:"quantity"`
	UnitPrice  float64 `json:"unit_price"`
}

// RemoveFromCartRequest represents the request to remove an item from cart
type RemoveFromCartRequest struct {
	UserID    string `json:"user_id"`
	ProductID string `json:"product_id"`
}

// Response represents a generic response
type Response struct {
	Success bool   `json:"success"`
	Message string `json:"message,omitempty"`
	State   string `json:"state,omitempty"`
	Order   *Order `json:"order,omitempty"`
}

var orderService = NewOrderService()

//encore:api public method=POST path=/orders/cart/add
func AddToCart(ctx context.Context, req *AddToCartRequest) (*Response, error) {
	// Create new order if none exists
	if orderService.GetCurrentOrder() == nil {
		orderService.CreateOrder(req.UserID)
		if err := orderService.Transition(ctx, EventAddToCart); err != nil {
			return nil, err
		}
	}

	// Add item to cart
	item := CartItem{
		ProductID:  req.ProductID,
		Quantity:   req.Quantity,
		UnitPrice:  req.UnitPrice,
	}
	if err := orderService.AddToCart(item); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Item added to cart",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}

//encore:api public method=POST path=/orders/cart/remove
func RemoveFromCart(ctx context.Context, req *RemoveFromCartRequest) (*Response, error) {
	if orderService.GetCurrentOrder() == nil || 
	   orderService.GetCurrentOrder().UserID != req.UserID {
		return nil, errs.B().Code(errs.NotFound).Msg("no active cart found").Err()
	}

	if err := orderService.RemoveFromCart(req.ProductID); err != nil {
		return nil, err
	}

	if err := orderService.Transition(ctx, EventRemoveFromCart); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Item removed from cart",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}

//encore:api public method=POST path=/orders/create
func CreateOrder(ctx context.Context) (*Response, error) {
	if orderService.GetCurrentOrder() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active cart found").Err()
	}

	if err := orderService.Transition(ctx, EventCreateOrder); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Order created successfully",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}

//encore:api public method=POST path=/orders/payment/initiate
func InitiatePayment(ctx context.Context) (*Response, error) {
	if orderService.GetCurrentOrder() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active order found").Err()
	}

	if err := orderService.Transition(ctx, EventInitiatePayment); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Payment initiated",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}

//encore:api public method=POST path=/orders/payment/complete
func CompletePayment(ctx context.Context) (*Response, error) {
	if orderService.GetCurrentOrder() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active order found").Err()
	}

	if err := orderService.Transition(ctx, EventPaymentSuccess); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Payment completed successfully",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}

//encore:api public method=POST path=/orders/fulfill
func FulfillOrder(ctx context.Context) (*Response, error) {
	if orderService.GetCurrentOrder() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active order found").Err()
	}

	if err := orderService.Transition(ctx, EventFulfillOrder); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Order fulfilled",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}

//encore:api public method=POST path=/orders/cancel
func CancelOrder(ctx context.Context) (*Response, error) {
	if orderService.GetCurrentOrder() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active order found").Err()
	}

	if err := orderService.Transition(ctx, EventCancelOrder); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Order cancelled",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}

//encore:api public method=POST path=/orders/refund/request
func RequestRefund(ctx context.Context) (*Response, error) {
	if orderService.GetCurrentOrder() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active order found").Err()
	}

	if err := orderService.Transition(ctx, EventRequestRefund); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Refund requested",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}

//encore:api public method=POST path=/orders/subscription/create
func CreateSubscription(ctx context.Context) (*Response, error) {
	if orderService.GetCurrentOrder() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active order found").Err()
	}

	if err := orderService.Transition(ctx, EventCreateSubscription); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Subscription created",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}

//encore:api public method=POST path=/orders/subscription/activate
func ActivateSubscription(ctx context.Context) (*Response, error) {
	if orderService.GetCurrentOrder() == nil || orderService.GetCurrentOrder().Subscription == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active subscription found").Err()
	}

	if err := orderService.Transition(ctx, EventActivateSubscription); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Subscription activated",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}

//encore:api public method=POST path=/orders/subscription/pause
func PauseSubscription(ctx context.Context) (*Response, error) {
	if orderService.GetCurrentOrder() == nil || orderService.GetCurrentOrder().Subscription == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active subscription found").Err()
	}

	if err := orderService.Transition(ctx, EventPauseSubscription); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Subscription paused",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}

//encore:api public method=POST path=/orders/subscription/resume
func ResumeSubscription(ctx context.Context) (*Response, error) {
	if orderService.GetCurrentOrder() == nil || orderService.GetCurrentOrder().Subscription == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active subscription found").Err()
	}

	if err := orderService.Transition(ctx, EventResumeSubscription); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Subscription resumed",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}

//encore:api public method=POST path=/orders/subscription/cancel
func CancelSubscription(ctx context.Context) (*Response, error) {
	if orderService.GetCurrentOrder() == nil || orderService.GetCurrentOrder().Subscription == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active subscription found").Err()
	}

	if err := orderService.Transition(ctx, EventCancelSubscription); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Subscription cancelled",
		State:   string(orderService.GetCurrentOrder().State),
		Order:   orderService.GetCurrentOrder(),
	}, nil
}
