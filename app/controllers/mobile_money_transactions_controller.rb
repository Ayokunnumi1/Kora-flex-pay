class MobileMoneyTransactionsController < ApplicationController
  def index
    @mobile_money_transaction = current_user.mobile_money_transactions.all

    # Count the total unique customers
    @total_customers = MobileMoneyTransaction.select(:customer_name).distinct.count

    # Get the total number of transactions for each customer
    @total_frequent_customers = MobileMoneyTransaction
                                  .group(:customer_name)
                                  .having('COUNT(*) > 1')
                                  .count
                                  .size
  end

  def new
    # Initialize a new mobile money transaction for the current user
    @mobile_money_transaction = current_user.mobile_money_transactions.new
  end

  def create
    service_charge = mobile_money_transaction_params[:amount].to_f * 1.05

    # Build the resource parameters for Kora API
    resource_params = {
      amount: service_charge.to_i, # Use service_charge here
      currency: mobile_money_transaction_params[:currency],
      default_channel: 'pay_with_bank',
      reference: SecureRandom.uuid,  # Generate a unique reference for the transaction
      customer: {
        name: mobile_money_transaction_params[:customer_name],
        email: mobile_money_transaction_params[:customer_email]
      }
    }

    # Call the Kora API via the service class using the built resource parameters
    api_service = Services.new(ENV.fetch('API_KEY', nil))
    response = api_service.create_resource(resource_params)

    if response.success?
      # If the API response is successful, create and save the transaction
      @mobile_money_transaction = current_user.mobile_money_transactions.new(
        mobile_money_transaction_params.merge(amount: service_charge)
      )

      if @mobile_money_transaction.save
        # Redirect to KoraPay checkout page
        redirect_to response.parsed_response['data']['checkout_url'], allow_other_host: true
      else
        # If saving fails, show errors in the form
        render :new
      end
    else
      # Handle errors from the API response if it fails
      handle_error_response(response)
    end
  end

  private

  # Method to handle error response from the Kora API
  def handle_error_response(response)
    # Display a flash message with the error and render the new form again
    flash[:alert] = "Error initializing payment: #{response.parsed_response['message']}"
    render :new
  end

  # Strong parameters to prevent mass assignment vulnerabilities
  def mobile_money_transaction_params
    # Only allow the following parameters to be submitted
    params.require(:mobile_money_transaction).permit(:amount, :currency, :customer_name, :customer_email)
  end
end