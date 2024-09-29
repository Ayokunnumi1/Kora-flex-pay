class AdminsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @users_with_mobile_money_count = User
      .left_joins(:mobile_money_transactions, :payouts)
      .select(
        'users.*,
      COUNT(DISTINCT mobile_money_transactions.id) as transactions_count,
      COUNT(DISTINCT CASE WHEN payouts.paid = false THEN payouts.id END) as unpaid_payouts_count'
      )
      .group('users.id')

    @balance = current_admin.fetch_balance
  end
end
