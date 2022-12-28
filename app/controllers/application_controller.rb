class ApplicationController < ActionController::API
	before_action :authorize_request , only: [:update, :show]
	

  def not_found
    render json: { error: 'not_found' }
  end

  def authorize_request
  	byebug
    header = request.headers['token']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  private
    def validate_json_web_token
      token = request.headers[:token] || params[:token]
      begin
        @token = JsonWebToken.decode(token)
      rescue *ERROR_CLASSES => exception
        handle_exception exception
      end
    end

    
end
