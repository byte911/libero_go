package payment

import (
	"context"

	"encore.dev/beta/errs"
)

// CreatePaymentRequest represents the request to create a new payment
type CreatePaymentRequest struct {
	OrderID  string  `json:"order_id"`
	UserID   string  `json:"user_id"`
	Amount   float64 `json:"amount"`
	Currency string  `json:"currency"`
}

// Response represents a generic response
type Response struct {
	Success bool     `json:"success"`
	Message string   `json:"message,omitempty"`
	State   string   `json:"state,omitempty"`
	Payment *Payment `json:"payment,omitempty"`
}

var paymentService = NewPaymentService()

//encore:api public method=POST path=/payments/create
func CreatePaymentTransaction(ctx context.Context, req *CreatePaymentRequest) (*Response, error) {
	payment := paymentService.CreatePayment(req.OrderID, req.UserID, req.Amount, req.Currency)
	return &Response{
		Success: true,
		Message: "Payment transaction created",
		State:   string(payment.State),
		Payment: payment,
	}, nil
}

//encore:api public method=POST path=/payments/apple/init
func InitiateApplePay(ctx context.Context) (*Response, error) {
	if paymentService.GetCurrentPayment() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active payment found").Err()
	}

	if err := paymentService.Transition(ctx, EventInitApplePay); err != nil {
		return nil, err
	}

	paymentService.GetCurrentPayment().PaymentMethod = "apple_pay"
	return &Response{
		Success: true,
		Message: "Apple Pay initiated",
		State:   string(paymentService.GetCurrentPayment().State),
		Payment: paymentService.GetCurrentPayment(),
	}, nil
}

//encore:api public method=POST path=/payments/apple/authorize
func AuthorizeApplePay(ctx context.Context) (*Response, error) {
	if paymentService.GetCurrentPayment() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active payment found").Err()
	}

	if err := paymentService.Transition(ctx, EventAppleAuthRequest); err != nil {
		return nil, err
	}

	// Simulate successful authorization
	if err := paymentService.Transition(ctx, EventAppleAuthSuccess); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Apple Pay authorized",
		State:   string(paymentService.GetCurrentPayment().State),
		Payment: paymentService.GetCurrentPayment(),
	}, nil
}

//encore:api public method=POST path=/payments/apple/process
func ProcessApplePay(ctx context.Context) (*Response, error) {
	if paymentService.GetCurrentPayment() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active payment found").Err()
	}

	if err := paymentService.Transition(ctx, EventAppleProcess); err != nil {
		return nil, err
	}

	// Simulate successful processing
	if err := paymentService.Transition(ctx, EventAppleSuccess); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Apple Pay processed",
		State:   string(paymentService.GetCurrentPayment().State),
		Payment: paymentService.GetCurrentPayment(),
	}, nil
}

//encore:api public method=POST path=/payments/google/init
func InitiateGooglePay(ctx context.Context) (*Response, error) {
	if paymentService.GetCurrentPayment() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active payment found").Err()
	}

	if err := paymentService.Transition(ctx, EventInitGooglePay); err != nil {
		return nil, err
	}

	paymentService.GetCurrentPayment().PaymentMethod = "google_pay"
	return &Response{
		Success: true,
		Message: "Google Pay initiated",
		State:   string(paymentService.GetCurrentPayment().State),
		Payment: paymentService.GetCurrentPayment(),
	}, nil
}

//encore:api public method=POST path=/payments/google/authorize
func AuthorizeGooglePay(ctx context.Context) (*Response, error) {
	if paymentService.GetCurrentPayment() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active payment found").Err()
	}

	if err := paymentService.Transition(ctx, EventGoogleAuthRequest); err != nil {
		return nil, err
	}

	// Simulate successful authorization
	if err := paymentService.Transition(ctx, EventGoogleAuthSuccess); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Google Pay authorized",
		State:   string(paymentService.GetCurrentPayment().State),
		Payment: paymentService.GetCurrentPayment(),
	}, nil
}

//encore:api public method=POST path=/payments/google/process
func ProcessGooglePay(ctx context.Context) (*Response, error) {
	if paymentService.GetCurrentPayment() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active payment found").Err()
	}

	if err := paymentService.Transition(ctx, EventGoogleProcess); err != nil {
		return nil, err
	}

	// Simulate successful processing
	if err := paymentService.Transition(ctx, EventGoogleSuccess); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Google Pay processed",
		State:   string(paymentService.GetCurrentPayment().State),
		Payment: paymentService.GetCurrentPayment(),
	}, nil
}

//encore:api public method=POST path=/payments/refund/request
func RequestRefund(ctx context.Context) (*Response, error) {
	if paymentService.GetCurrentPayment() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active payment found").Err()
	}

	if err := paymentService.Transition(ctx, EventRequestRefund); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Refund requested",
		State:   string(paymentService.GetCurrentPayment().State),
		Payment: paymentService.GetCurrentPayment(),
	}, nil
}

//encore:api public method=POST path=/payments/refund/process
func ProcessRefund(ctx context.Context) (*Response, error) {
	if paymentService.GetCurrentPayment() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active payment found").Err()
	}

	if err := paymentService.Transition(ctx, EventProcessRefund); err != nil {
		return nil, err
	}

	// Simulate successful refund
	if err := paymentService.Transition(ctx, EventRefundSuccess); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Refund processed",
		State:   string(paymentService.GetCurrentPayment().State),
		Payment: paymentService.GetCurrentPayment(),
	}, nil
}

//encore:api public method=POST path=/payments/retry
func RetryPayment(ctx context.Context) (*Response, error) {
	if paymentService.GetCurrentPayment() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active payment found").Err()
	}

	if err := paymentService.Transition(ctx, EventRetryPayment); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Payment retry initiated",
		State:   string(paymentService.GetCurrentPayment().State),
		Payment: paymentService.GetCurrentPayment(),
	}, nil
}

//encore:api public method=POST path=/payments/cancel
func CancelPayment(ctx context.Context) (*Response, error) {
	if paymentService.GetCurrentPayment() == nil {
		return nil, errs.B().Code(errs.NotFound).Msg("no active payment found").Err()
	}

	if err := paymentService.Transition(ctx, EventCancelPayment); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Payment cancelled",
		State:   string(paymentService.GetCurrentPayment().State),
		Payment: paymentService.GetCurrentPayment(),
	}, nil
}
