class UsersController < ApplicationController
  before_action :authenticate_user!,  unless: :admin_signed_in?
  def index
    @user = current_user
    # @user_balance = @user.fetch_balance
    # @bank_transfers = @user.bank_transfers
    # @payouts = @user.payouts
    @mobile_money_transaction = @user.mobile_money_transactions
  end

  def show
    @user = User.find(params[:id])
    @payouts = @user.payouts
  end

  private

  def admin_signed_in?
    current_admin.present?
  end
end
