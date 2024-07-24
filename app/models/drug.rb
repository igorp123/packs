class Drug < ApplicationRecord
  has_many :batch
  has_many :sgtin

  def full_name
    "#{name} #{form_name} #{form_doze} (МНН: #{mnn}) "
  end
end
