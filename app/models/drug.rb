class Drug < ApplicationRecord
  has_many :batch
  has_many :sgtin
  belongs_to :producer

  def full_name
    "#{name} #{form_name} #{form_doze} (МНН: #{mnn})"
  end
end
