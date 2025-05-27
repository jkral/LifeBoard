module TurboStreamResponses
  extend ActiveSupport::Concern

  included do
    before_action :set_turbo_stream_variant
  end

  private

  def set_turbo_stream_variant
    request.variant = :turbo_stream if turbo_frame_request?
  end

  def respond_with_turbo_stream(location: nil, notice: nil, alert: nil)
    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = notice if notice
        flash.now[:alert] = alert if alert
      end
      format.html do
        flash[:notice] = notice if notice
        flash[:alert] = alert if alert
        redirect_to location if location
      end
      format.json { render :show, status: :ok, location: location }
    end
  end

  def handle_turbo_errors(resource, location: nil, action: nil)
    action ||= params[:action]
    
    respond_to do |format|
      format.turbo_stream do
        flash.now[:alert] = resource.errors.full_messages.to_sentence
        render action: action, status: :unprocessable_entity
      end
      format.html do
        flash.now[:alert] = resource.errors.full_messages.to_sentence
        render action: action, status: :unprocessable_entity
      end
      format.json { render json: resource.errors, status: :unprocessable_entity }
    end
  end

  def render_turbo_stream(action, **locals)
    render turbo_stream: turbo_stream.update(
      params[:target],
      partial: action,
      locals: locals
    )
  end
end
