class PayoutsController < ApplicationController
  before_action :set_payout, only: %i[edit update]

  def new
    @payout = current_user.payouts.new(
      reference: generate_reference,
      currency: current_user.currency,
      bank_code: current_user.bank_code,
      account_number: current_user.account_number,
      customer_name: "#{current_user.first_name} #{current_user.last_name}",
      customer_email: current_user.email
    )
  end

  def create
    if payout_params[:amount].to_f > current_user.available_balance
      flash.now[:alert] = 'Insufficient balance for this payout.'
      render :new
    else
      @payout = current_user.payouts.new(payout_params)
      @payout.admin_id = Admin.first.id

      if @payout.save
        redirect_to users_path(@payout), notice: 'Payout was successfully created.'
      else
        flash.now[:alert] = 'Failed to create payout.'
        render :new
      end
    end
  end

  def edit

  end

  def update
    if create_payout_api(@payout)
      @payout.update(paid: true)
      redirect_to admins_index_path, notice: 'Payout was successfully processed.'
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
      'Authorization' => "Bearer #{ENV.fetch('API_KEY', nil)}",
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
    if response.code == 200 && response.parsed_response['status']
      true
    else
      Rails.logger.error("API Error: #{response.body}")
      false
    end
  end

  def generate_reference
    unique_code = SecureRandom.hex(4)
    timestamp = Time.now.to_i
    "unique-reference-#{timestamp}#{unique_code}"
  end
end
