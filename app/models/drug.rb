class Drug < ApplicationRecord
  has_many :batch, dependent: :delete_all
  has_many :sgtin, dependent: :delete_all
  belongs_to :producer

  def full_name
    "#{name} #{form_name} #{form_doze} (МНН: #{mnn})"
  end
end
