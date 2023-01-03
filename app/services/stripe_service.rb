require 'stripe'
class StripeService
	def initialize()
		Stripe.api_key = ENV['STRIPE_SECRET_KEY']
	end

	def find_or_create_customer(customer)
		if customer.stripe_customer_id.present?
			stripe_customer = Stripe::Customer.retrieve(customer.stripe_customer_id)
		else
			stripe_customer = Stripe::Customer.create({name: customer.name, email: customer.email, phone: customer.phone_number})
			customer.update(stripe_customer_id: stripe_customer.id)

		end
		stripe_customer
	end
  def create_card_token(params)
  	Stripe::Token.create({
  		card: {
  			number: params[:card_number].to_s,
  			exp_month: params[:exp_month],
  			exp_year: params[:exp_year],
  			cvc: params[:cvv]
  		}
  	})
  end
  	
  def create_stripe_customer_card(params,stripe_customer)
  	token = create_card_token(params)
  	Stripe::Customer.create_source(
		  stripe_customer.id,
		  {source: token.id},
		)
  end

  def create_stripe_charge(token,stripe_customer,params)
  	# workshop = Stripe::Workshop.first

  	Stripe::Charge.create({
  		amount: params[:amount] * 100,
  		customer: stripe_customer.id,
  		currency: "usd",
  		source: token.id,
  		description: "Amount $#{params[:amount]} charged for this registration"
  	})
  end

end
