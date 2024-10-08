class User < ApplicationRecord
  # include HTTParty
  has_many :bank_transfers
  has_many :payouts
  has_many :mobile_money_transactions

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_create :generate_unique_identifier

  validates :unique_identifier, uniqueness: true
  validates :first_name, :last_name, :bank_name, :bank_code, :account_number, :phone_number, :currency, presence: true

  private

  def generate_unique_identifier
    self.unique_identifier = SecureRandom.uuid
  end
end
