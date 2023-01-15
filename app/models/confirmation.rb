class Confirmation < ApplicationRecord
  belongs_to :confirmable, polymorphic: true
end
