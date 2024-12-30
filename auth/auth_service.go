package auth

import (
	"context"
	"time"

	"encore.dev/beta/errs"
)

// AuthState represents the current state of the authentication process
type AuthState string

const (
	StateStart                  AuthState = "start"
	StateAuthenticating        AuthState = "authenticating"
	StateAuthenticatingApple   AuthState = "authenticating_apple"
	StateAuthenticatingGoogle  AuthState = "authenticating_google"
	StateWaitingAppleCallback  AuthState = "waiting_apple_callback"
	StateWaitingGoogleCallback AuthState = "waiting_google_callback"
	StateSendingEmailCode      AuthState = "sending_email_code"
	StateWaitingEmailCode      AuthState = "waiting_email_code"
	StateVerifyingEmailCode    AuthState = "verifying_email_code"
	StateAuthenticated         AuthState = "authenticated"
	StateError                 AuthState = "error"
	StateLoggedOut            AuthState = "logged_out"

	// Account deletion states
	StateDeletionRequested        AuthState = "deletion_requested"
	StateVerifyingDeletionPassword AuthState = "verifying_deletion_password"
	StateVerifyingDeletionApple    AuthState = "verifying_deletion_apple"
	StateVerifyingDeletionGoogle   AuthState = "verifying_deletion_google"
	StateVerifyingDeletionEmail    AuthState = "verifying_deletion_email"
	StateWaitingDeletionEmailCode  AuthState = "waiting_deletion_email_code"
	StateConfirmingDeletion        AuthState = "confirming_deletion"
	StateAccountDeleted            AuthState = "account_deleted"
)

// AuthEvent represents events that can trigger state transitions
type AuthEvent string

const (
	EventLogin          AuthEvent = "login"
	EventLoginApple     AuthEvent = "login_apple"
	EventLoginGoogle    AuthEvent = "login_google"
	EventLoginEmail     AuthEvent = "login_email"
	EventAppleCallback  AuthEvent = "apple_callback"
	EventGoogleCallback AuthEvent = "google_callback"
	EventAuthOK         AuthEvent = "auth_ok"
	EventAuthFail       AuthEvent = "auth_fail"
	EventLogout        AuthEvent = "logout"
	EventError         AuthEvent = "error"
	EventRetry         AuthEvent = "retry"
	EventSendCode      AuthEvent = "send_code"
	EventCodeSent      AuthEvent = "code_sent"
	EventSubmitCode    AuthEvent = "submit_code"
	EventCodeValid     AuthEvent = "code_valid"
	EventCodeInvalid   AuthEvent = "code_invalid"
	EventCodeExpired   AuthEvent = "code_expired"
	EventResendCode    AuthEvent = "resend_code"

	// Account deletion events
	EventRequestDeletion   AuthEvent = "request_deletion"
	EventVerifyPassword    AuthEvent = "verify_password"
	EventVerifyApple      AuthEvent = "verify_apple"
	EventVerifyGoogle     AuthEvent = "verify_google"
	EventVerifyEmail      AuthEvent = "verify_email"
	EventDeletionVerified AuthEvent = "deletion_verified"
	EventDeletionDenied   AuthEvent = "deletion_denied"
	EventConfirmDeletion  AuthEvent = "confirm_deletion"
	EventCancelDeletion   AuthEvent = "cancel_deletion"
	EventDeletionComplete AuthEvent = "deletion_complete"
)

// AuthService manages the authentication state machine
type AuthService struct {
	currentState AuthState
	session     *Session
}

type Session struct {
	UserID    string
	ExpiresAt time.Time
}

// NewAuthService creates a new instance of AuthService
func NewAuthService() *AuthService {
	return &AuthService{
		currentState: StateStart,
	}
}

// Transition attempts to transition the auth state based on the given event
func (s *AuthService) Transition(ctx context.Context, event AuthEvent) error {
	nextState, err := s.computeNextState(event)
	if err != nil {
		return err
	}

	// Perform any necessary side effects based on the transition
	if err := s.handleTransition(ctx, event, nextState); err != nil {
		return err
	}

	s.currentState = nextState
	return nil
}

// computeNextState determines the next state based on current state and event
func (s *AuthService) computeNextState(event AuthEvent) (AuthState, error) {
	switch s.currentState {
	case StateStart:
		switch event {
		case EventLogin:
			return StateAuthenticating, nil
		case EventLoginApple:
			return StateAuthenticatingApple, nil
		case EventLoginGoogle:
			return StateAuthenticatingGoogle, nil
		case EventLoginEmail:
			return StateSendingEmailCode, nil
		}

	case StateAuthenticating:
		switch event {
		case EventAuthOK:
			return StateAuthenticated, nil
		case EventAuthFail, EventError:
			return StateError, nil
		}

	case StateAuthenticatingApple:
		switch event {
		case EventAuthOK:
			return StateWaitingAppleCallback, nil
		case EventAuthFail, EventError:
			return StateError, nil
		}

	case StateWaitingAppleCallback:
		switch event {
		case EventAppleCallback:
			return StateAuthenticated, nil
		case EventAuthFail, EventError:
			return StateError, nil
		}

	case StateAuthenticatingGoogle:
		switch event {
		case EventAuthOK:
			return StateWaitingGoogleCallback, nil
		case EventAuthFail, EventError:
			return StateError, nil
		}

	case StateWaitingGoogleCallback:
		switch event {
		case EventGoogleCallback:
			return StateAuthenticated, nil
		case EventAuthFail, EventError:
			return StateError, nil
		}

	case StateSendingEmailCode:
		switch event {
		case EventCodeSent:
			return StateWaitingEmailCode, nil
		case EventError:
			return StateError, nil
		}

	case StateWaitingEmailCode:
		switch event {
		case EventSubmitCode:
			return StateVerifyingEmailCode, nil
		case EventResendCode:
			return StateSendingEmailCode, nil
		case EventCodeExpired:
			return StateError, nil
		}

	case StateVerifyingEmailCode:
		switch event {
		case EventCodeValid:
			return StateAuthenticated, nil
		case EventCodeInvalid:
			return StateWaitingEmailCode, nil
		case EventError:
			return StateError, nil
		}

	case StateAuthenticated:
		switch event {
		case EventLogout:
			return StateLoggedOut, nil
		case EventRequestDeletion:
			return StateDeletionRequested, nil
		}

	case StateDeletionRequested:
		switch event {
		case EventVerifyPassword:
			return StateVerifyingDeletionPassword, nil
		case EventVerifyApple:
			return StateVerifyingDeletionApple, nil
		case EventVerifyGoogle:
			return StateVerifyingDeletionGoogle, nil
		case EventVerifyEmail:
			return StateVerifyingDeletionEmail, nil
		}

	case StateVerifyingDeletionPassword:
		switch event {
		case EventDeletionVerified:
			return StateConfirmingDeletion, nil
		case EventDeletionDenied:
			return StateAuthenticated, nil
		}

	case StateVerifyingDeletionApple:
		switch event {
		case EventDeletionVerified:
			return StateConfirmingDeletion, nil
		case EventDeletionDenied:
			return StateAuthenticated, nil
		}

	case StateVerifyingDeletionGoogle:
		switch event {
		case EventDeletionVerified:
			return StateConfirmingDeletion, nil
		case EventDeletionDenied:
			return StateAuthenticated, nil
		}

	case StateVerifyingDeletionEmail:
		switch event {
		case EventCodeSent:
			return StateWaitingDeletionEmailCode, nil
		case EventDeletionVerified:
			return StateConfirmingDeletion, nil
		case EventDeletionDenied:
			return StateAuthenticated, nil
		}

	case StateWaitingDeletionEmailCode:
		switch event {
		case EventSubmitCode:
			return StateVerifyingDeletionEmail, nil
		case EventCodeExpired:
			return StateAuthenticated, nil
		}

	case StateConfirmingDeletion:
		switch event {
		case EventConfirmDeletion:
			return StateAccountDeleted, nil
		case EventCancelDeletion:
			return StateAuthenticated, nil
		}

	case StateAccountDeleted:
		switch event {
		case EventLogin:
			return StateStart, nil
		}

	case StateError:
		switch event {
		case EventRetry:
			return StateStart, nil
		}

	case StateLoggedOut:
		switch event {
		case EventLogin:
			return StateAuthenticating, nil
		case EventLoginApple:
			return StateAuthenticatingApple, nil
		case EventLoginGoogle:
			return StateAuthenticatingGoogle, nil
		case EventLoginEmail:
			return StateSendingEmailCode, nil
		}
	}

	return "", errs.B().Code(errs.InvalidArgument).Msg("invalid state transition").Err()
}

// handleTransition performs any necessary side effects for state transitions
func (s *AuthService) handleTransition(ctx context.Context, event AuthEvent, nextState AuthState) error {
	switch nextState {
	case StateAuthenticated:
		// Create a new session
		s.session = &Session{
			UserID:    "user-123", // Replace with actual user ID
			ExpiresAt: time.Now().Add(24 * time.Hour),
		}
	case StateLoggedOut:
		// Clear the session
		s.session = nil
	case StateAccountDeleted:
		// Clear all user data
		s.session = nil
	}
	return nil
}

// GetCurrentState returns the current state of the auth service
func (s *AuthService) GetCurrentState() AuthState {
	return s.currentState
}

// GetSession returns the current session if it exists
func (s *AuthService) GetSession() *Session {
	return s.session
}
