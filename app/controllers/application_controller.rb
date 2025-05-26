class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  helper_method :current_user
  
  private
  
  def current_user
    @current_user ||= begin
      session = Session.find_by(id: cookies.signed[:session_id])
      session&.user
    end
  end
  
  # Override the request_authentication method to ensure consistent redirect behavior
  def request_authentication
    store_location_for(:user, request.fullpath) if request.get? && !request.xhr?
    redirect_to login_path, alert: "Please log in to continue."
  end
  
  # Store the URL the user was trying to access before being redirected to login
  def store_location_for(resource_or_scope, location)
    session_key = "#{resource_or_scope}_return_to"
    session[session_key] = location
  end
  
  # Get the stored location for a resource after sign in
  def stored_location_for(resource_or_scope)
    session_key = "#{resource_or_scope}_return_to"
    session.delete(session_key)
  end
end
