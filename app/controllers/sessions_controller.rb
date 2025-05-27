class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      Rails.logger.info "User authenticated: #{user.email_address}"
      session = start_new_session_for(user)
      if session.persisted?
        Rails.logger.info "Session created: #{session.id}, cookie set: #{cookies.signed[:session_id].present?}"
        # Redirect to the stored location or the default after authentication URL
        redirect_to stored_location_for(:user) || after_authentication_url
      else
        Rails.logger.error "Failed to create session: #{session.errors.full_messages}"
        redirect_to new_session_path, alert: "Failed to create session. Please try again."
      end
    else
      Rails.logger.warn "Failed login attempt for email: #{params[:email_address]}"
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
