class User < ApplicationRecord
  include HTTParty
  has_many :bank_transfers
  has_many :payouts
  has_many :mobile_money_transactions

  base_uri 'https://api.korapay.com/merchant/api/v1'

  def fetch_balance
    response = self.class.get('/balances', headers: { "Authorization" => "Bearer #{kora_api_sk}" })

    puts response.parsed_response  # To debug the response

    if response.success?
      data = response.parsed_response
      {
        pending_balance: data.dig('data', 'NGN', 'pending_balance'),
        available_balance: data.dig('data', 'NGN', 'available_balance')
      }
    else
      { error: response.message }
    end
  end
end
