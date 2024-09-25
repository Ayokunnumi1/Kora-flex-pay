class UsersController < ApplicationController
  def index
    @user = current_user
    @user_balance = @user.fetch_balance
    @bank_transfers = @user.bank_transfers
    @payouts = @user.payouts
    @mobile_money_transaction = @user.mobile_money_transactions
  end
end
