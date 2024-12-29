package order

import (
	"context"
	"time"

	"encore.dev/beta/errs"
)

// OrderState represents the current state of an order
type OrderState string

const (
	// Order states
	StateStart            OrderState = "start"
	StateCartPending      OrderState = "cart_pending"
	StateOrderCreated     OrderState = "order_created"
	StatePaymentPending   OrderState = "payment_pending"
	StatePaymentProcessing OrderState = "payment_processing"
	StatePaymentFailed    OrderState = "payment_failed"
	StateOrderPaid        OrderState = "order_paid"
	StateOrderFulfilled   OrderState = "order_fulfilled"
	StateOrderCancelled   OrderState = "order_cancelled"
	StateOrderRefunded    OrderState = "order_refunded"

	// Subscription states
	StateSubscriptionCreated      OrderState = "subscription_created"
	StateSubscriptionActive       OrderState = "subscription_active"
	StateSubscriptionPaymentDue   OrderState = "subscription_payment_due"
	StateSubscriptionPaymentFailed OrderState = "subscription_payment_failed"
	StateSubscriptionPaused       OrderState = "subscription_paused"
	StateSubscriptionCancelled    OrderState = "subscription_cancelled"
	StateSubscriptionExpired      OrderState = "subscription_expired"

	// Common states
	StateError OrderState = "error"
)

// OrderEvent represents events that can trigger state transitions
type OrderEvent string

const (
	// Order events
	EventAddToCart       OrderEvent = "add_to_cart"
	EventRemoveFromCart  OrderEvent = "remove_from_cart"
	EventCreateOrder     OrderEvent = "create_order"
	EventUpdateOrder     OrderEvent = "update_order"
	EventCancelOrder     OrderEvent = "cancel_order"
	EventInitiatePayment OrderEvent = "initiate_payment"
	EventPaymentSuccess  OrderEvent = "payment_success"
	EventPaymentFailed   OrderEvent = "payment_failed"
	EventRetryPayment    OrderEvent = "retry_payment"
	EventRequestRefund   OrderEvent = "request_refund"
	EventApproveRefund   OrderEvent = "approve_refund"
	EventDenyRefund      OrderEvent = "deny_refund"
	EventFulfillOrder    OrderEvent = "fulfill_order"

	// Subscription events
	EventCreateSubscription    OrderEvent = "create_subscription"
	EventActivateSubscription  OrderEvent = "activate_subscription"
	EventPauseSubscription     OrderEvent = "pause_subscription"
	EventResumeSubscription    OrderEvent = "resume_subscription"
	EventCancelSubscription    OrderEvent = "cancel_subscription"
	EventRenewSubscription     OrderEvent = "renew_subscription"
	EventPaymentDue           OrderEvent = "payment_due"
	EventGracePeriodExpired   OrderEvent = "grace_period_expired"

	// Common events
	EventError OrderEvent = "error"
	EventRetry OrderEvent = "retry"
)

// CartItem represents an item in the shopping cart
type CartItem struct {
	ProductID   string  `json:"product_id"`
	Quantity    int     `json:"quantity"`
	UnitPrice   float64 `json:"unit_price"`
	TotalPrice  float64 `json:"total_price"`
}

// Order represents an order in the system
type Order struct {
	ID            string      `json:"id"`
	UserID        string      `json:"user_id"`
	Items         []CartItem  `json:"items"`
	TotalAmount   float64     `json:"total_amount"`
	State         OrderState  `json:"state"`
	CreatedAt     time.Time   `json:"created_at"`
	UpdatedAt     time.Time   `json:"updated_at"`
	PaymentID     string      `json:"payment_id,omitempty"`
	RefundID      string      `json:"refund_id,omitempty"`
	Subscription  *Subscription `json:"subscription,omitempty"`
}

// Subscription represents a subscription tied to an order
type Subscription struct {
	ID            string      `json:"id"`
	OrderID       string      `json:"order_id"`
	UserID        string      `json:"user_id"`
	State         OrderState  `json:"state"`
	StartDate     time.Time   `json:"start_date"`
	EndDate       time.Time   `json:"end_date"`
	NextBillingDate time.Time `json:"next_billing_date"`
	BillingAmount float64     `json:"billing_amount"`
	PaymentMethod string      `json:"payment_method"`
}

// OrderService manages the order state machine
type OrderService struct {
	currentOrder *Order
}

// NewOrderService creates a new instance of OrderService
func NewOrderService() *OrderService {
	return &OrderService{}
}

// Transition attempts to transition the order state based on the given event
func (s *OrderService) Transition(ctx context.Context, event OrderEvent) error {
	if s.currentOrder == nil {
		return errs.B().Code(errs.InvalidArgument).Msg("no active order").Err()
	}

	nextState, err := s.computeNextState(event)
	if err != nil {
		return err
	}

	// Perform any necessary side effects based on the transition
	if err := s.handleTransition(ctx, event, nextState); err != nil {
		return err
	}

	s.currentOrder.State = nextState
	s.currentOrder.UpdatedAt = time.Now()
	return nil
}

// computeNextState determines the next state based on current state and event
func (s *OrderService) computeNextState(event OrderEvent) (OrderState, error) {
	switch s.currentOrder.State {
	case StateStart:
		switch event {
		case EventAddToCart:
			return StateCartPending, nil
		}

	case StateCartPending:
		switch event {
		case EventAddToCart, EventRemoveFromCart:
			return StateCartPending, nil
		case EventCreateOrder:
			return StateOrderCreated, nil
		}

	case StateOrderCreated:
		switch event {
		case EventInitiatePayment:
			return StatePaymentPending, nil
		case EventCancelOrder:
			return StateOrderCancelled, nil
		}

	case StatePaymentPending:
		switch event {
		case EventPaymentSuccess:
			return StateOrderPaid, nil
		case EventPaymentFailed:
			return StatePaymentFailed, nil
		case EventCancelOrder:
			return StateOrderCancelled, nil
		case EventApproveRefund:
			return StateOrderRefunded, nil
		case EventDenyRefund:
			return StateOrderPaid, nil
		}

	case StatePaymentFailed:
		switch event {
		case EventRetryPayment:
			return StatePaymentProcessing, nil
		case EventCancelOrder:
			return StateOrderCancelled, nil
		}

	case StatePaymentProcessing:
		switch event {
		case EventPaymentSuccess:
			return StateOrderPaid, nil
		case EventPaymentFailed:
			return StatePaymentFailed, nil
		}

	case StateOrderPaid:
		switch event {
		case EventFulfillOrder:
			return StateOrderFulfilled, nil
		case EventRequestRefund:
			return StatePaymentPending, nil
		case EventCreateSubscription:
			return StateSubscriptionCreated, nil
		}

	case StateOrderFulfilled:
		switch event {
		case EventRequestRefund:
			return StatePaymentPending, nil
		}

	case StateSubscriptionCreated:
		switch event {
		case EventActivateSubscription:
			return StateSubscriptionActive, nil
		}

	case StateSubscriptionActive:
		switch event {
		case EventPaymentDue:
			return StateSubscriptionPaymentDue, nil
		case EventPauseSubscription:
			return StateSubscriptionPaused, nil
		case EventCancelSubscription:
			return StateSubscriptionCancelled, nil
		case EventRenewSubscription:
			return StateSubscriptionActive, nil
		}

	case StateSubscriptionPaymentDue:
		switch event {
		case EventPaymentSuccess:
			return StateSubscriptionActive, nil
		case EventPaymentFailed:
			return StateSubscriptionPaymentFailed, nil
		case EventCancelSubscription:
			return StateSubscriptionCancelled, nil
		}

	case StateSubscriptionPaymentFailed:
		switch event {
		case EventRetryPayment:
			return StateSubscriptionPaymentDue, nil
		case EventGracePeriodExpired:
			return StateSubscriptionExpired, nil
		case EventCancelSubscription:
			return StateSubscriptionCancelled, nil
		}

	case StateSubscriptionPaused:
		switch event {
		case EventResumeSubscription:
			return StateSubscriptionActive, nil
		case EventCancelSubscription:
			return StateSubscriptionCancelled, nil
		}

	case StateError:
		switch event {
		case EventRetry:
			return StateStart, nil
		}
	}

	return "", errs.B().Code(errs.InvalidArgument).Msg("invalid state transition").Err()
}

// handleTransition performs any necessary side effects for state transitions
func (s *OrderService) handleTransition(ctx context.Context, event OrderEvent, nextState OrderState) error {
	switch nextState {
	case StateOrderPaid:
		// Handle payment completion
		s.currentOrder.PaymentID = "payment-" + s.currentOrder.ID

	case StateOrderRefunded:
		// Handle refund completion
		s.currentOrder.RefundID = "refund-" + s.currentOrder.ID

	case StateSubscriptionCreated:
		// Create new subscription
		s.currentOrder.Subscription = &Subscription{
			ID:              "sub-" + s.currentOrder.ID,
			OrderID:         s.currentOrder.ID,
			UserID:          s.currentOrder.UserID,
			State:           StateSubscriptionCreated,
			StartDate:       time.Now(),
			EndDate:         time.Now().AddDate(1, 0, 0), // 1 year subscription
			NextBillingDate: time.Now().AddDate(0, 1, 0), // Bill monthly
			BillingAmount:   s.currentOrder.TotalAmount,
			PaymentMethod:   "card", // Default payment method
		}
	}
	return nil
}

// GetCurrentOrder returns the current order if it exists
func (s *OrderService) GetCurrentOrder() *Order {
	return s.currentOrder
}

// CreateOrder initializes a new order
func (s *OrderService) CreateOrder(userID string) *Order {
	s.currentOrder = &Order{
		ID:        "order-" + time.Now().Format("20060102150405"),
		UserID:    userID,
		State:     StateStart,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	return s.currentOrder
}

// AddToCart adds an item to the current order's cart
func (s *OrderService) AddToCart(item CartItem) error {
	if s.currentOrder == nil {
		return errs.B().Code(errs.InvalidArgument).Msg("no active order").Err()
	}

	item.TotalPrice = item.UnitPrice * float64(item.Quantity)
	s.currentOrder.Items = append(s.currentOrder.Items, item)
	s.currentOrder.TotalAmount += item.TotalPrice
	return nil
}

// RemoveFromCart removes an item from the current order's cart
func (s *OrderService) RemoveFromCart(productID string) error {
	if s.currentOrder == nil {
		return errs.B().Code(errs.InvalidArgument).Msg("no active order").Err()
	}

	for i, item := range s.currentOrder.Items {
		if item.ProductID == productID {
			s.currentOrder.TotalAmount -= item.TotalPrice
			s.currentOrder.Items = append(s.currentOrder.Items[:i], s.currentOrder.Items[i+1:]...)
			return nil
		}
	}

	return errs.B().Code(errs.NotFound).Msg("item not found in cart").Err()
}
