class UsersController < ApplicationController
  def index
    @user = current_user
    @mobile_money_transaction = @user.mobile_money_transactions
    @total_customers = MobileMoneyTransaction.select(:customer_name).distinct.count
  end
end
