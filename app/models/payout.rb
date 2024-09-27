class Payout < ApplicationRecord
  belongs_to :admin
  belongs_to :user

  after_create :update_user_balance
  after_update :deduct_pending_withdraw, if: :paid_changed_to_true?

  private

  def update_user_balance
    user.update(available_balance: user.available_balance - amount)
    user.update(pending_withdraw: user.pending_withdraw + amount)
  end

  def deduct_pending_withdraw
    user.update(pending_withdraw: user.pending_withdraw - amount)
  end

  def paid_changed_to_true?
    saved_change_to_paid? && paid
  end
end
