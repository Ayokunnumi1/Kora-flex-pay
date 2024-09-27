class MobileMoneyTransaction < ApplicationRecord
  belongs_to :user

  after_create :update_user_balance

  private

  def update_user_balance
    new_balance = amount * 0.9619
    user.update(available_balance: user.available_balance + new_balance)
  end
end
