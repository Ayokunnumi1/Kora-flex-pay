class BankTransfersController < ApplicationController
  def new
    @bank_transfer = current_user.bank_transfers.new
  end

  def create
    @bank_transfer = current_user.bank_transfers.new(bank_transfer_params)

    if create_bank_transfer_api(@bank_transfer)
      @bank_transfer.save
      redirect_to users_path, notice: 'Bank transfer was successfully created.'
    else
      flash.now[:alert] = 'Failed to create bank transfer via API.'
      render :new
    end
  end

  private

  def bank_transfer_params
    params.require(:bank_transfer).permit(:account_name, :amount, :currency, :reference, :customer_name,
                                          :customer_email)
  end

  def create_bank_transfer_api(bank_transfer)
    response = HTTParty.post(
      api_url,
      headers: api_headers,
      body: api_payload(bank_transfer)
    )

    successful_response?(response)
  end

  def api_url
    'https://api.korapay.com/merchant/api/v1/charges/bank-transfer'
  end

  def api_headers
    {
      'Authorization' => "Bearer #{current_user.kora_api_sk}",
      'Content-Type' => 'application/json'
    }
  end

  def api_payload(bank_transfer)
    {
      account_name: bank_transfer.account_name,
      amount: bank_transfer.amount,
      currency: bank_transfer.currency,
      reference: bank_transfer.reference,
      customer: {
        name: bank_transfer.customer_name,
        email: bank_transfer.customer_email
      }
    }.to_json
  end

  def successful_response?(response)
    response.code == 200 && response.parsed_response['status']
  end
end
