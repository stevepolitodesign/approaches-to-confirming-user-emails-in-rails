class User < ApplicationRecord
  has_one :confirmation, as: :confirmable

  scope :unconfirmed, -> { where(confirmed_at: nil) }

  validates :email, uniqueness: true
end
