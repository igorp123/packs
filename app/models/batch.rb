class Batch < ApplicationRecord
  belongs_to :drug
  has_many :sgtin, dependent: :destroy
  has_many :batch_firms, dependent: :destroy
  has_many :firms, through: :batch_firms

  def formatted_expiration_date
    expiration_date.strftime('%d.%m.%Y')
  end
end
