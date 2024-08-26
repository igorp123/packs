class Firm < ApplicationRecord
  has_many :sgtin

  has_many :batch_firms, dependent: :destroy
  has_many :batches, through: :batch_firms
end
