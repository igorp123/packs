class Token < ApplicationRecord
  def formatted_expiration_date
    expiration_date.strftime('%d.%m.%Y')
  end
end
