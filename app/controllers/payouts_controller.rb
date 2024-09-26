class PayoutsController < ApplicationController
  def new
    @payout = current_user.payouts.new
  end

  def create
    @payout = current_user.payouts.new(payout_params)

    if create_payout_api(@payout)
      @payout.save
      redirect_to users_path, notice: 'Payout was successfully created.'
    else
      flash.now[:alert] = 'Failed to create payout via API'
      render :new
    end
  end

  private

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
end
