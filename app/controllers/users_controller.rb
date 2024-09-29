class UsersController < ApplicationController
  before_action :authenticate_user!, unless: :admin_signed_in?
  def index
    redirect_to admins_index_path and return if admin_signed_in?

    @user = current_user
    @mobile_money_transaction = @user.mobile_money_transactions
    @total_customers = MobileMoneyTransaction.select(:customer_name).distinct.count
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
