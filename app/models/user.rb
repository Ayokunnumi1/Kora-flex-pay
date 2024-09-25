class User < ApplicationRecord
  before_create :generate_unique_identifier

  validates :unique_identifier, uniqueness: true

  private

  def generate_unique_identifier
    self.unique_identifier = SecureRandom.uuid
  end
end
