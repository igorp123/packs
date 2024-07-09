class Sgtin < ApplicationRecord
  belongs_to :drug
  belongs_to :batch
  belongs_to :firm
end
