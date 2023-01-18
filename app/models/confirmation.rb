class Confirmation < ApplicationRecord
  belongs_to :confirmable, polymorphic: true

  validates :confirmable_type, uniqueness: { scope: :confirmable_id }
end
