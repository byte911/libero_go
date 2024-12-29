package payment

import (
	"context"
	"time"

	"encore.dev/beta/errs"
)

// PaymentState represents the current state of a payment
type PaymentState string

const (
	// Initial state
	StateStart PaymentState = "start"

	// Apple Pay states
	StateApplePayInitiated   PaymentState = "apple_pay_initiated"
	StateApplePayAuthorizing PaymentState = "apple_pay_authorizing"
	StateApplePayAuthorized  PaymentState = "apple_pay_authorized"
	StateApplePayProcessing  PaymentState = "apple_pay_processing"
	StateApplePayCompleted   PaymentState = "apple_pay_completed"
	StateApplePayFailed      PaymentState = "apple_pay_failed"

	// Google Pay states
	StateGooglePayInitiated   PaymentState = "google_pay_initiated"
	StateGooglePayAuthorizing PaymentState = "google_pay_authorizing"
	StateGooglePayAuthorized  PaymentState = "google_pay_authorized"
	StateGooglePayProcessing  PaymentState = "google_pay_processing"
	StateGooglePayCompleted   PaymentState = "google_pay_completed"
	StateGooglePayFailed      PaymentState = "google_pay_failed"

	// Common states
	StatePaymentCompleted PaymentState = "payment_completed"
	StatePaymentFailed    PaymentState = "payment_failed"
	StatePaymentRefunding PaymentState = "payment_refunding"
	StatePaymentRefunded  PaymentState = "payment_refunded"
	StateError           PaymentState = "error"
)

// PaymentEvent represents events that can trigger state transitions
type PaymentEvent string

const (
	// Apple Pay events
	EventInitApplePay     PaymentEvent = "init_apple_pay"
	EventAppleAuthRequest PaymentEvent = "apple_auth_request"
	EventAppleAuthSuccess PaymentEvent = "apple_auth_success"
	EventAppleAuthFailed  PaymentEvent = "apple_auth_failed"
	EventAppleProcess     PaymentEvent = "apple_process"
	EventAppleSuccess     PaymentEvent = "apple_success"
	EventAppleFailed      PaymentEvent = "apple_failed"

	// Google Pay events
	EventInitGooglePay     PaymentEvent = "init_google_pay"
	EventGoogleAuthRequest PaymentEvent = "google_auth_request"
	EventGoogleAuthSuccess PaymentEvent = "google_auth_success"
	EventGoogleAuthFailed  PaymentEvent = "google_auth_failed"
	EventGoogleProcess     PaymentEvent = "google_process"
	EventGoogleSuccess     PaymentEvent = "google_success"
	EventGoogleFailed      PaymentEvent = "google_failed"

	// Common events
	EventRequestRefund PaymentEvent = "request_refund"
	EventProcessRefund PaymentEvent = "process_refund"
	EventRefundSuccess PaymentEvent = "refund_success"
	EventRefundFailed  PaymentEvent = "refund_failed"
	EventRetryPayment  PaymentEvent = "retry_payment"
	EventError        PaymentEvent = "error"
	EventCancelPayment PaymentEvent = "cancel_payment"
)

// Payment represents a payment transaction
type Payment struct {
	ID            string       `json:"id"`
	OrderID       string       `json:"order_id"`
	UserID        string       `json:"user_id"`
	Amount        float64      `json:"amount"`
	Currency      string       `json:"currency"`
	State         PaymentState `json:"state"`
	PaymentMethod string       `json:"payment_method"` // "apple_pay" or "google_pay"
	CreatedAt     time.Time    `json:"created_at"`
	UpdatedAt     time.Time    `json:"updated_at"`
	CompletedAt   *time.Time   `json:"completed_at,omitempty"`
	RefundedAt    *time.Time   `json:"refunded_at,omitempty"`
	ErrorMessage  string       `json:"error_message,omitempty"`
}

// PaymentService manages the payment state machine
type PaymentService struct {
	currentPayment *Payment
}

// NewPaymentService creates a new instance of PaymentService
func NewPaymentService() *PaymentService {
	return &PaymentService{}
}

// CreatePayment initializes a new payment
func (s *PaymentService) CreatePayment(orderID, userID string, amount float64, currency string) *Payment {
	s.currentPayment = &Payment{
		ID:        "payment-" + time.Now().Format("20060102150405"),
		OrderID:   orderID,
		UserID:    userID,
		Amount:    amount,
		Currency:  currency,
		State:     StateStart,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	return s.currentPayment
}

// Transition attempts to transition the payment state based on the given event
func (s *PaymentService) Transition(ctx context.Context, event PaymentEvent) error {
	if s.currentPayment == nil {
		return errs.B().Code(errs.InvalidArgument).Msg("no active payment").Err()
	}

	nextState, err := s.computeNextState(event)
	if err != nil {
		return err
	}

	// Perform any necessary side effects based on the transition
	if err := s.handleTransition(ctx, event, nextState); err != nil {
		return err
	}

	s.currentPayment.State = nextState
	s.currentPayment.UpdatedAt = time.Now()
	return nil
}

// computeNextState determines the next state based on current state and event
func (s *PaymentService) computeNextState(event PaymentEvent) (PaymentState, error) {
	switch s.currentPayment.State {
	case StateStart:
		switch event {
		case EventInitApplePay:
			return StateApplePayInitiated, nil
		case EventInitGooglePay:
			return StateGooglePayInitiated, nil
		}

	// Apple Pay Flow
	case StateApplePayInitiated:
		switch event {
		case EventAppleAuthRequest:
			return StateApplePayAuthorizing, nil
		}

	case StateApplePayAuthorizing:
		switch event {
		case EventAppleAuthSuccess:
			return StateApplePayAuthorized, nil
		case EventAppleAuthFailed:
			return StateApplePayFailed, nil
		}

	case StateApplePayAuthorized:
		switch event {
		case EventAppleProcess:
			return StateApplePayProcessing, nil
		}

	case StateApplePayProcessing:
		switch event {
		case EventAppleSuccess:
			return StateApplePayCompleted, nil
		case EventAppleFailed:
			return StateApplePayFailed, nil
		}

	case StateApplePayCompleted:
		return StatePaymentCompleted, nil

	case StateApplePayFailed:
		switch event {
		case EventRetryPayment:
			return StateApplePayInitiated, nil
		case EventCancelPayment:
			return StatePaymentFailed, nil
		}

	// Google Pay Flow
	case StateGooglePayInitiated:
		switch event {
		case EventGoogleAuthRequest:
			return StateGooglePayAuthorizing, nil
		}

	case StateGooglePayAuthorizing:
		switch event {
		case EventGoogleAuthSuccess:
			return StateGooglePayAuthorized, nil
		case EventGoogleAuthFailed:
			return StateGooglePayFailed, nil
		}

	case StateGooglePayAuthorized:
		switch event {
		case EventGoogleProcess:
			return StateGooglePayProcessing, nil
		}

	case StateGooglePayProcessing:
		switch event {
		case EventGoogleSuccess:
			return StateGooglePayCompleted, nil
		case EventGoogleFailed:
			return StateGooglePayFailed, nil
		}

	case StateGooglePayCompleted:
		return StatePaymentCompleted, nil

	case StateGooglePayFailed:
		switch event {
		case EventRetryPayment:
			return StateGooglePayInitiated, nil
		case EventCancelPayment:
			return StatePaymentFailed, nil
		}

	// Refund Flow
	case StatePaymentCompleted:
		switch event {
		case EventRequestRefund:
			return StatePaymentRefunding, nil
		}

	case StatePaymentRefunding:
		switch event {
		case EventProcessRefund:
			return StatePaymentRefunding, nil
		case EventRefundSuccess:
			return StatePaymentRefunded, nil
		case EventRefundFailed:
			return StatePaymentCompleted, nil
		}

	case StateError:
		switch event {
		case EventRetryPayment:
			return StateStart, nil
		}
	}

	return "", errs.B().Code(errs.InvalidArgument).Msg("invalid state transition").Err()
}

// handleTransition performs any necessary side effects for state transitions
func (s *PaymentService) handleTransition(ctx context.Context, event PaymentEvent, nextState PaymentState) error {
	switch nextState {
	case StatePaymentCompleted:
		now := time.Now()
		s.currentPayment.CompletedAt = &now

	case StatePaymentRefunded:
		now := time.Now()
		s.currentPayment.RefundedAt = &now

	case StateApplePayFailed, StateGooglePayFailed:
		s.currentPayment.ErrorMessage = "Payment processing failed"

	case StateError:
		s.currentPayment.ErrorMessage = "System error occurred"
	}
	return nil
}

// GetCurrentPayment returns the current payment if it exists
func (s *PaymentService) GetCurrentPayment() *Payment {
	return s.currentPayment
}
