class Batch < ApplicationRecord
  belongs_to :drug
  has_many :sgtin

  def formatted_expiration_date
    expiration_date.strftime('%d.%m.%Y')
  end
end
