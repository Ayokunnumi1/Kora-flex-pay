class UsersController < ApplicationController
  def index
    @user = current_user
    @user_balance = @user.fetch_balance
    @bank_transfers = @user.bank_transfers
    @payouts = @user.payouts
  end
end
