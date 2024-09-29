class Services
  include HTTParty

  base_uri 'https://api.korapay.com/merchant'

  def initialize(api_key)
    @options = {
      headers: {
        'Authorization' => "Bearer #{api_key}",
        'Content-Type' => 'application/json'
      }
    }
  end

  # POST request
  def create_resource(resource_params)
    self.class.post('/api/v1/charges/initialize', { body: resource_params.to_json }.merge(@options))
  end
end
