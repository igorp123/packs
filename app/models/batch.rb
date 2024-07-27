class Batch < ApplicationRecord
  belongs_to :drug
  has_many :sgtin, dependent: :delete_all

  def formatted_expiration_date
    expiration_date.strftime('%d.%m.%Y')
  end
end
