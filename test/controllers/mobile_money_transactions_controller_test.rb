require 'test_helper'

class MobileMoneyTransactionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get create' do
    get mobile_money_transactions_create_url
    assert_response :success
  end
end
