class AdminsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @users_with_mobile_money_count = User
                                      .left_joins(:mobile_money_transactions)
                                      .select('users.*, COUNT(mobile_money_transactions.id) as transactions_count')
                                      .group('users.id')

    @balance = current_admin.fetch_balance
  end
end
