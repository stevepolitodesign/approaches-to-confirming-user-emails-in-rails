class User < ApplicationRecord
  has_many :confirmations, as: :confirmable

  scope :unconfirmed, -> { where(confirmed_at: nil) }

  validates :email, uniqueness: true
end
