class Sgtin < ApplicationRecord
  belongs_to :drug
  belongs_to :batch
  belongs_to :firm

  def formatted_status_date
    status_date.strftime('%d.%m.%Y')
  end

  def formatted_last_operation_date
    last_operation_date.strftime('%d.%m.%Y')
  end
end
