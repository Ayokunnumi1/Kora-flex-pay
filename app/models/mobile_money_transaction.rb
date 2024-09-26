class MobileMoneyTransaction < ApplicationRecord
    belongs_to :user
# validates :amount, presence: true, numericality: { greater_than: 0 }
#   validates :currency, presence: true
#   validates :customer_name, presence: true
#   validates :customer_email, presence: true
end
