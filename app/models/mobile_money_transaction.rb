class MobileMoneyTransaction < ApplicationRecord
  belongs_to :user

  after_create :update_user_balance

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :customer_name, presence: true
  validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  private

  def update_user_balance
    new_balance = amount * 0.9619
    user.update(available_balance: user.available_balance + new_balance)
  end
end
