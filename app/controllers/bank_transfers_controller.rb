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
    params.require(:bank_transfer).permit(:account_name, :amount, :currency, :reference, :customer_name, :customer_email)
  end

  def create_bank_transfer_api(bank_transfer)
    # Define the API endpoint and headers
    url = 'https://api.korapay.com/merchant/api/v1/charges/bank-transfer'
    headers = {
      'Authorization' => "Bearer #{current_user.kora_api_sk}",
      'Content-Type' => 'application/json'
    }

    # Define the payload
    payload = {
      account_name: bank_transfer.account_name,
      amount: bank_transfer.amount,
      currency: bank_transfer.currency,
      reference: bank_transfer.reference,
      customer: {
        name: bank_transfer.customer_name,
        email: bank_transfer.customer_email
      }
    }.to_json

    # Make the API request
    response = HTTParty.post(url, headers: headers, body: payload)

    # Check if the API request was successful
    if response.code == 200 && response.parsed_response['status']
      true
    else
      false
    end
  end
end
