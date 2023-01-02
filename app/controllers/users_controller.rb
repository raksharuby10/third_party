class UsersController < ApplicationController
	skip_before_action :authorize_request, only: [:create, :destory]
    before_action :validate_json_web_token, only: [:update, :show]
	before_action :set_user, only: [:show, :destory]
  def index
	 	@users = User.all
	 	render json: @users, status: :ok
	end 

	def show
		render json: @user, status: :ok
	end

	def create
		@user = User.new(user_params)
		if @user.save
			render json: @user, status: :created
		else
			render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
		end
	end

	def update
		@user = User.find(@token[:user_id])
		unless @user.update(user_params)
			render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
		end
	end

	def destroy
		byebug
		@user = User.find(params[:id])
		@user.destroy
	end

	private

	def user_params
		params.permit(:name,:username, :email, :password, :id)
	end

	def set_user
		@user = User.find(params[:id])
	end
end
