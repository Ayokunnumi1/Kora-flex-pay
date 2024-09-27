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

    # Create a new mobile money transaction with the parameters provided by the form
    @mobile_money_transaction = current_user.mobile_money_transactions.new(
      mobile_money_transaction_params.merge(amount: service_charge)
    )

    if @mobile_money_transaction.save
      resource_params = build_resource_params(@mobile_money_transaction)

      # Call the Kora API via the service class using the built resource parameters
      api_service = Services.new(ENV.fetch('API_KEY', nil))
      response = api_service.create_resource(resource_params)

      if response.success?
        # If the API response is successful, redirect the user to the KoraPay checkout page
        # Note: We removed the duplicate creation of MobileMoneyTransaction here
        redirect_to response.parsed_response['data']['checkout_url'], allow_other_host: true
      else
        # Handle errors from the API response if it fails
        handle_error_response(response)
      end
    else
      # If saving the transaction fails, re-render the form with the errors
      render :new
    end
  end

  private

  # Method to build the parameters for the Kora API request
  def build_resource_params(transaction)
    {
      amount: transaction.amount.to_i,
      currency: transaction.currency,
      default_channel: 'pay_with_bank',
      reference: SecureRandom.uuid, # Generate a unique reference for the transaction
      customer: {
        name: transaction.customer_name,
        email: transaction.customer_email
      }
    }
  end

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
