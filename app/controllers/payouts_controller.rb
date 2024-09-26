class PayoutsController < ApplicationController
  before_action :set_payout, only: [:edit, :update]

  def new
    @payout = current_user.payouts.new(
      reference: generate_reference, # Assuming you have a method to generate a unique reference
      currency: 'NGN', # Default currency
      bank_code: current_user.bank_code, # Autofill from user data
      account_number: current_user.account_number, # Autofill from user data
      customer_name: current_user.first_name + ' ' + current_user.last_name, # Autofill from user data
      customer_email: current_user.email # Autofill from user data
    )
  end

  def create
    @payout = current_user.payouts.new(payout_params)
    @payout.admin_id = Admin.first.id # Automatically set admin_id to the first admin in the database

    if @payout.save
      redirect_to edit_payout_path(@payout), notice: 'Payout was successfully created. You can now process it.'
    else
      flash.now[:alert] = 'Failed to create payout.'
      render :new
    end
  end

  def edit
    # @payout is set by the before_action
  end

  def update
    if create_payout_api(@payout)
      redirect_to users_path, notice: 'Payout was successfully processed.'
    else
      flash.now[:alert] = 'Failed to create payout via API'
      render :edit
    end
  end

  private

  def set_payout
    @payout = Payout.find(params[:id])
  end

  def payout_params
    params.require(:payout).permit(:reference, :amount, :currency, :bank_code, :account_number, :narration,
                                   :customer_name, :customer_email)
  end

  def create_payout_api(payout)
    url = 'https://api.korapay.com/merchant/api/v1/transactions/disburse'
    headers = build_headers
    payload = build_payload(payout)

    response = HTTParty.post(url, headers:, body: payload)

    successful_response?(response)
  end

  def build_headers
    {
      'Authorization' => "Bearer #{current_user.kora_api_sk}",
      'Content-Type' => 'application/json'
    }
  end

  def build_payload(payout)
    {
      reference: payout.reference,
      destination: {
        type: 'bank_account',
        amount: payout.amount.to_s,
        currency: payout.currency,
        narration: payout.narration,
        bank_account: {
          bank: payout.bank_code,
          account: payout.account_number
        },
        customer: {
          name: payout.customer_name,
          email: payout.customer_email
        }
      }
    }.to_json
  end

  def successful_response?(response)
    response.code == 200 && response.parsed_response['status']
  end

  def generate_reference
    # Implement your logic to generate a unique reference here
  end
end
