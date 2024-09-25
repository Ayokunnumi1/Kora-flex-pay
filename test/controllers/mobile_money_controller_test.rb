require "test_helper"

class MobileMoneyControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get mobile_money_create_url
    assert_response :success
  end
end
