class Batch < ApplicationRecord
  belongs_to :drug
  has_many :sgtin
end
