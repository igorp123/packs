class Drug < ApplicationRecord
  has_many :batch, dependent: :destroy
  has_many :sgtin, dependent: :destroy
  belongs_to :producer

  validates :gtin, presence: true, uniqueness: true

  def full_name
    "#{name} #{form_name} #{form_doze} (МНН: #{mnn})"
  end
end
