package auth

import (
	"context"

	"encore.dev/beta/errs"
)

// LoginRequest represents the request body for traditional login
type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

// EmailLoginRequest represents the request for email-based login
type EmailLoginRequest struct {
	Email string `json:"email"`
}

// VerifyCodeRequest represents the request for verifying email codes
type VerifyCodeRequest struct {
	Email string `json:"email"`
	Code  string `json:"code"`
}

// DeletionVerifyRequest represents the request for verifying deletion
type DeletionVerifyRequest struct {
	Method   string `json:"method"` // "password", "apple", "google", "email"
	Password string `json:"password,omitempty"`
	Token    string `json:"token,omitempty"`
}

// Response represents a generic response
type Response struct {
	Success bool   `json:"success"`
	Message string `json:"message,omitempty"`
	State   string `json:"state"`
}

var authService = NewAuthService()

//encore:api public method=POST path=/auth/login
func Login(ctx context.Context, req *LoginRequest) (*Response, error) {
	if err := authService.Transition(ctx, EventLogin); err != nil {
		return nil, err
	}

	// Simulate authentication (replace with actual authentication logic)
	if req.Username == "test" && req.Password == "test" {
		if err := authService.Transition(ctx, EventAuthOK); err != nil {
			return nil, err
		}
		return &Response{
			Success: true,
			Message: "Login successful",
			State:   string(authService.GetCurrentState()),
		}, nil
	}

	if err := authService.Transition(ctx, EventAuthFail); err != nil {
		return nil, err
	}
	return nil, &errs.Error{
		Code:    errs.Unauthenticated,
		Message: "Invalid credentials",
	}
}

//encore:api public method=POST path=/auth/login/apple
func LoginWithApple(ctx context.Context) (*Response, error) {
	if err := authService.Transition(ctx, EventLoginApple); err != nil {
		return nil, err
	}

	// Simulate Apple authentication success
	if err := authService.Transition(ctx, EventAuthOK); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Waiting for Apple callback",
		State:   string(authService.GetCurrentState()),
	}, nil
}

//encore:api public method=POST path=/auth/login/google
func LoginWithGoogle(ctx context.Context) (*Response, error) {
	if err := authService.Transition(ctx, EventLoginGoogle); err != nil {
		return nil, err
	}

	// Simulate Google authentication success
	if err := authService.Transition(ctx, EventAuthOK); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Waiting for Google callback",
		State:   string(authService.GetCurrentState()),
	}, nil
}

//encore:api public method=POST path=/auth/login/email
func LoginWithEmail(ctx context.Context, req *EmailLoginRequest) (*Response, error) {
	if err := authService.Transition(ctx, EventLoginEmail); err != nil {
		return nil, err
	}

	// Simulate sending email code
	if err := authService.Transition(ctx, EventCodeSent); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Verification code sent",
		State:   string(authService.GetCurrentState()),
	}, nil
}

//encore:api public method=POST path=/auth/verify-code
func VerifyEmailCode(ctx context.Context, req *VerifyCodeRequest) (*Response, error) {
	if err := authService.Transition(ctx, EventSubmitCode); err != nil {
		return nil, err
	}

	// Simulate code verification (replace with actual verification logic)
	if req.Code == "123456" {
		if err := authService.Transition(ctx, EventCodeValid); err != nil {
			return nil, err
		}
		return &Response{
			Success: true,
			Message: "Code verified successfully",
			State:   string(authService.GetCurrentState()),
		}, nil
	}

	if err := authService.Transition(ctx, EventCodeInvalid); err != nil {
		return nil, err
	}
	return nil, &errs.Error{
		Code:    errs.InvalidArgument,
		Message: "Invalid verification code",
	}
}

//encore:api public method=POST path=/auth/logout
func Logout(ctx context.Context) (*Response, error) {
	if err := authService.Transition(ctx, EventLogout); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Logged out successfully",
		State:   string(authService.GetCurrentState()),
	}, nil
}

//encore:api public method=POST path=/auth/request-deletion
func RequestDeletion(ctx context.Context) (*Response, error) {
	if err := authService.Transition(ctx, EventRequestDeletion); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Deletion requested",
		State:   string(authService.GetCurrentState()),
	}, nil
}

//encore:api public method=POST path=/auth/verify-deletion
func VerifyDeletion(ctx context.Context, req *DeletionVerifyRequest) (*Response, error) {
	var event AuthEvent
	switch req.Method {
	case "password":
		event = EventVerifyPassword
	case "apple":
		event = EventVerifyApple
	case "google":
		event = EventVerifyGoogle
	case "email":
		event = EventVerifyEmail
	default:
		return nil, &errs.Error{
			Code:    errs.InvalidArgument,
			Message: "Invalid verification method",
		}
	}

	if err := authService.Transition(ctx, event); err != nil {
		return nil, err
	}

	// Simulate verification (replace with actual verification logic)
	if (req.Method == "password" && req.Password == "test") ||
		(req.Method != "password" && req.Token == "valid_token") {
		if err := authService.Transition(ctx, EventDeletionVerified); err != nil {
			return nil, err
		}
		return &Response{
			Success: true,
			Message: "Deletion verified",
			State:   string(authService.GetCurrentState()),
		}, nil
	}

	if err := authService.Transition(ctx, EventDeletionDenied); err != nil {
		return nil, err
	}
	return nil, &errs.Error{
		Code:    errs.PermissionDenied,
		Message: "Verification failed",
	}
}

//encore:api public method=POST path=/auth/confirm-deletion
func ConfirmDeletion(ctx context.Context) (*Response, error) {
	if err := authService.Transition(ctx, EventConfirmDeletion); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Account deleted successfully",
		State:   string(authService.GetCurrentState()),
	}, nil
}

//encore:api public method=POST path=/auth/cancel-deletion
func CancelDeletion(ctx context.Context) (*Response, error) {
	if err := authService.Transition(ctx, EventCancelDeletion); err != nil {
		return nil, err
	}

	return &Response{
		Success: true,
		Message: "Deletion cancelled",
		State:   string(authService.GetCurrentState()),
	}, nil
}
