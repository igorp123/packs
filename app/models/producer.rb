class Producer < ApplicationRecord
  has_many :drug, dependent: :delete_all
end
