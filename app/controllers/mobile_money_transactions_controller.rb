class MobileMoneyTransactionsController < ApplicationController
  def index
    @mobile_money_transaction = current_user.mobile_money_transactions.order(created_at: :desc)

    @total_customers = MobileMoneyTransaction.select(:customer_name).distinct.count

    @total_frequent_customers = MobileMoneyTransaction
      .group(:customer_name)
      .having('COUNT(*) > 1')
      .count
      .size
  end

  def new
    @mobile_money_transaction = current_user.mobile_money_transactions.new
  end

  def create
    @mobile_money_transaction = build_mobile_money_transaction
    resource_params = build_resource_params(@mobile_money_transaction)

    api_service = Services.new(ENV.fetch('API_KEY', nil))
    response = api_service.create_resource(resource_params)

    if response.success?
      save_transaction(response)
    else
      handle_error_response(response)
    end
  end

  private

  def build_mobile_money_transaction
    service_charge = mobile_money_transaction_params[:amount].to_f * 1.05
    current_user.mobile_money_transactions.new(
      mobile_money_transaction_params.merge(amount: service_charge)
    )
  end

  def build_resource_params(transaction)
    {
      amount: transaction.amount.to_i,
      currency: transaction.currency,
      default_channel: 'pay_with_bank',
      reference: SecureRandom.uuid,
      customer: {
        name: transaction.customer_name,
        email: transaction.customer_email
      }
    }
  end

  def save_transaction(response)
    if @mobile_money_transaction.save
      redirect_to response.parsed_response['data']['checkout_url'], allow_other_host: true
    else
      render :new
    end
  end

  def handle_error_response(response)
    flash[:alert] = "Error initializing payment: #{response.parsed_response['message']}"
    render :new
  end

  def mobile_money_transaction_params
    params.require(:mobile_money_transaction).permit(:amount, :currency, :customer_name, :customer_email)
  end
end
