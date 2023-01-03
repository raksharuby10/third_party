class UsersController < ApplicationController
	skip_before_action :authorize_request, only: [:create, :destory]
    before_action :validate_json_web_token, only: [:update, :show,:stripe_method]
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
		@user = User.find(params[:id])
		@user.destroy
	end

	def stripe_method
		@user = User.find(@token[:user_id])
		stripe_init = StripeService.new()
        stripe_customer = stripe_init.find_or_create_customer(@user)
        token = stripe_init.create_stripe_customer_card(params,stripe_customer)
        stripe_init.create_stripe_charge(token,stripe_customer,params)
        # render json: stripe_customer, status: "payment success"
	end

	private

	def user_params
		params.permit(:name,:username,:email, :password, :id, :phone_number)
	end

	def set_user
		@user = User.find(params[:id])
	end
end
