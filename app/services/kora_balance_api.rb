class KoraBalanceApi
  include HTTParty
  base_uri 'https://api.korapay.com/merchant/api/v1'

  def fetch_balance
    api_key = ENV['API_KEY']  # Fetch API key from the .env file

    response = self.class.get('/balances', headers: { "Authorization" => "Bearer #{api_key}" })

    puts response.parsed_response  # For debugging purposes

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
