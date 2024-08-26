class Producer < ApplicationRecord
  has_many :drug, dependent: :destroy
end
