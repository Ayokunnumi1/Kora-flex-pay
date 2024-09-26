class MobileMoneyTransactionsController < ApplicationController

  def new
    @mobile_money_transaction = current_user.mobile_money_transactions.new
  end

  def create
    @mobile_money_transaction = current_user.mobile_money_transactions.new(mobile_money_transaction_params)

    if @mobile_money_transaction.save
   
      resource_params = {
        amount: @mobile_money_transaction.amount.to_i, 
        currency: @mobile_money_transaction.currency, 
        default_channel: "pay_with_bank",
        reference: SecureRandom.uuid,
        customer: {
          name: @mobile_money_transaction.customer_name,
          email: @mobile_money_transaction.customer_email
        }
      }

      # Call the Kora API via the service class
      api_service = Services.new(ENV['API_KEY'])
      response = api_service.create_resource(resource_params)

      if response.success?
      # Save the transaction in the database, associating it with the current user
      MobileMoneyTransaction.create(
        amount: params[:amount].to_i,
        currency: params[:currency],
        customer_name: params[:name],
        customer_email: params[:email],
        user_id: current_user.id  # Associate with the current user
      )

        # Extract the checkout URL from the response
        checkout_url = response.parsed_response['data']['checkout_url']

        # Redirect to the KoraPay payment page
        redirect_to checkout_url, allow_other_host: true
      else
        # Handle error from Kora API
        flash[:alert] = "Error initializing payment: #{response.parsed_response['message']}"
        render :new
      end
    else
      # If saving the transaction fails, re-render the form
      render :new
    end
  end

  private

  # Strong parameters to prevent mass assignment vulnerabilities
   def mobile_money_transaction_params
    params.require(:mobile_money_transaction).permit(:amount, :currency, :customer_name, :customer_email)
  end
end
