class User < ApplicationRecord
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  validates :email, uniqueness: true
end
