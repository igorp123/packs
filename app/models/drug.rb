class Drug < ApplicationRecord
  has_many :batch
  has_many :sgtin
end
