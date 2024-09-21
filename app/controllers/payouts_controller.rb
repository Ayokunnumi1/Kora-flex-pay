class PayoutsController < ApplicationController
  def new
    @payout = Payout.new
  end

  def create
    @payout = current_user.payouts.new(payout_params)

    body = {
      reference: @payout.reference,
      destination: {
        type: 'bank_account',
        amount: @payout.amount.to_s,
        currency: @payout.currency,
        narration: @payout.narration,
        bank_account: {
          bank: @payout.bank_code,
          account: @payout.account_number
        },
        customer: {
          name: @payout.customer_name,
          email: @payout.customer_email
        }
      }
    }

    response = HTTParty.post(
      'https://api.korapay.com/merchant/api/v1/transactions/disburse',
      headers: {
        "Authorization" => "Bearer #{current_user.kora_api_sk}",
        'Content-Type' => 'application/json'
      },
      body: body.to_json
    )

    parsed_response = response.parsed_response

    if response.success? && parsed_response['status'] == 'success'
      @payout.status = 'processing'
      if @payout.save
        respond_to do |format|
          format.html { redirect_to users_path, notice: 'Payout initiated successfully.' }
          format.turbo_stream { redirect_to users_path, notice: 'Payout initiated successfully.' }
        end
      else
        flash[:alert] = 'Failed to save payout in the database.'
        render :new
      end
    else
      flash[:alert] = "Failed to initiate payout: #{parsed_response['message']}"
      render :new
    end
  end

  private

  def payout_params
    params.require(:payout).permit(:reference, :amount, :currency, :bank_code, :account_number, :narration, :customer_name, :customer_email)
  end
end